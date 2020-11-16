//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification
import UIKit
import Combine

final class RiskProvider {

	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let targetQueue: DispatchQueue
	private var consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")
	private let riskCalculation: RiskCalculationProtocol
	private var keyPackageDownload: KeyPackageDownloadProtocol
	private let exposureDetectionExecutor: ExposureDetectionDelegate
	private var exposureDetection: ExposureDetection?

	private var _consumers: [RiskConsumer] = []
	private var consumers: [RiskConsumer] {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	private var subscriptions = [AnyCancellable]()

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		riskCalculation: RiskCalculationProtocol = RiskCalculation(),
		keyPackageDownload: KeyPackageDownloadProtocol,
		exposureDetectionExecutor: ExposureDetectionDelegate
	) {
		self.riskProvidingConfiguration = configuration
		self.store = store
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
		self.riskCalculation = riskCalculation
		self.keyPackageDownload = keyPackageDownload
		self.exposureDetectionExecutor = exposureDetectionExecutor

		self.registerForPackageDownloadStatusUpdate()
	}


	// MARK: Properties
	private let store: Store
	private let appConfigurationProvider: AppConfigurationProviding
	private(set) var activityState: ActivityState = .idle
	var exposureManagerState: ExposureManagerState

	var riskProvidingConfiguration: RiskProvidingConfiguration
}

private extension RiskConsumer {
	func provideRiskCalculationResult(_ result: RiskCalculationResult) {
		switch result {
		case .success(let risk):
			targetQueue.async { [weak self] in
				self?.didCalculateRisk(risk)
			}
		case .failure(let error):
			targetQueue.async { [weak self] in
				self?.didFailCalculateRisk(error)
			}
		}
	}
}

extension RiskProvider: RiskProviding {

	func observeRisk(_ consumer: RiskConsumer) {
		consumers.append(consumer)
	}

	func removeRisk(_ consumer: RiskConsumer) {
		consumers.removeAll(where: { $0 === consumer })
	}

	var manualExposureDetectionState: ManualExposureDetectionState? {
		riskProvidingConfiguration.manualExposureDetectionState(
			activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
			lastExposureDetectionDate: store.summary?.date)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	/// The completion is only used for the background fetch. Please use a consumer to get state updates.
	func requestRisk(userInitiated: Bool, ignoreCachedSummary: Bool = false, completion: Completion? = nil) {
		Log.info("RiskProvider: Request risk was called. UserInitiated: \(userInitiated), ignoreCachedSummary: \(ignoreCachedSummary)", log: .riskDetection)

		guard activityState == .idle else {
			Log.info("RiskProvider: Risk detection is allready running. Don't start new risk detection", log: .riskDetection)
			targetQueue.async {
				// This completion callback only affects the background fetch.
				// (Since at the moment the background fetch is the only one using the completion)
				completion?(.failure(.riskProviderIsRunning))
			}
			return
		}

		queue.async {
			self.updateActivityState(.riskRequested)

			#if DEBUG
			if isUITesting {
				self._requestRiskLevel_Mock(userInitiated: userInitiated, completion: completion)
				return
			}
			#endif

			self._requestRiskLevel(userInitiated: userInitiated, ignoreCachedSummary: ignoreCachedSummary, completion: completion)
		}
	}

	/// Returns the next possible date of a exposureDetection
	/// Case1: Date is a valid date in the future
	/// Case2: Date is in the past (could be .distantPast) (usually happens when no detection has been run before (e.g. fresh install).
	/// For Case2, we need to calculate the remaining time until we reach a full 24h of tracing.
	func nextExposureDetectionDate() -> Date {
		let nextDate = riskProvidingConfiguration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.summary?.date
		)
		switch nextDate {
		case .now:  // Occurs when no detection has been performed ever
			let tracingHistory = store.tracingStatusHistory
			let numberOfEnabledSeconds = tracingHistory.activeTracing().interval
			let remainingTime = TracingStatusHistory.minimumActiveSeconds - numberOfEnabledSeconds
			// To get a more robust Date when calculating the Date we need to drop precision, otherwise we will get dates differing in miliseconds
			let timeInterval = Date().addingTimeInterval(remainingTime).timeIntervalSinceReferenceDate
			let timeIntervalInSeconds = Int(timeInterval)
			return Date(timeIntervalSinceReferenceDate: TimeInterval(timeIntervalInSeconds))
		case .date(let date):
			return date
		}
	}


	private func successOnTargetQueue(risk: Risk, completion: Completion?) {
		Log.info("RiskProvider: Risk detection and calculation was successful.", log: .riskDetection)

		updateActivityState(.idle)

		targetQueue.async {
			completion?(.success(risk))
		}

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}
	}

	private func failOnTargetQueue(error: RiskProviderError, completion: Completion?) {
		Log.info("RiskProvider: Failed with error: \(error)", log: .riskDetection)

		updateActivityState(.idle)

		targetQueue.async {
			completion?(.failure(error))
		}

		for consumer in consumers {
			_provideRiskResult(.failure(error), to: consumer)
		}
	}

	private func _requestRiskLevel(userInitiated: Bool, ignoreCachedSummary: Bool, completion: Completion?) {
		let group = DispatchGroup()
		group.enter()
		appConfigurationProvider.appConfiguration().sink { [weak self] configuration in
			guard let self = self else { return }

			self.updateRiskProvidingConfiguration(with: configuration)

			self.downloadKeyPackages { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success:
					self.determineRisk(
						userInitiated: userInitiated,
						ignoreCachedSummary: ignoreCachedSummary,
						appConfiguration: configuration) { result in

						switch result {
						case .success(let risk):
							self.successOnTargetQueue(risk: risk, completion: completion)
						case .failure(let error):
							self.failOnTargetQueue(error: error, completion: completion)
						}

						group.leave()
					}
				case .failure(let error):
					self.failOnTargetQueue(error: error, completion: completion)
					group.leave()
				}
			}
		}.store(in: &subscriptions)

		guard group.wait(timeout: .now() + .seconds(60 * 8)) == .success else {
			updateActivityState(.idle)
			exposureDetection?.cancel()
			Log.info("RiskProvider: Canceled risk calculation due to timeout", log: .riskDetection)
			failOnTargetQueue(error: .timeout, completion: completion)
			return
		}
	}

	private func downloadKeyPackages(completion: @escaping (Result<Void, RiskProviderError>) -> Void) {
		// The result of a hour package download is not handled, because for the risk detection it is irrelevant if it fails or not.
		self.downloadHourPackages { [weak self] in
			guard let self = self else { return }

			self.downloadDayPackages(completion: { result in
				completion(result)
			})
		}
	}

	private func downloadDayPackages(completion: @escaping (Result<Void, RiskProviderError>) -> Void) {
		keyPackageDownload.startDayPackagesDownload(completion: { result in
			switch result {
			case .success:
				completion(.success(()))
			case .failure(let error):
				completion(.failure(.failedKeyPackageDownload(error)))
			}
		})
	}

	private func downloadHourPackages(completion: @escaping () -> Void) {
		keyPackageDownload.startHourPackagesDownload(completion: { _ in
			completion()
		})
	}

	private func determineRisk(
		userInitiated: Bool,
		ignoreCachedSummary: Bool,
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping Completion
	) {
		if let risk = self.riskForMissingPreconditions() {
			Log.info("RiskProvider: Determined Risk from preconditions", log: .riskDetection)
			completion(.success(risk))
			return
		}

		self.determineSummary(
			userInitiated: userInitiated,
			ignoreCachedSummary: ignoreCachedSummary,
			appConfiguration: appConfiguration,
			completion: { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let summary):
					self.calculateRiskLevel(
						summary: summary,
						appConfiguration: appConfiguration,
						completion: completion
					)
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}

	private func riskForMissingPreconditions() -> Risk? {
		let tracingHistory = self.store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.activeTracing().inHours

		let details = Risk.Details(
			daysSinceLastExposure: self.store.summary?.summary.daysSinceLastExposure,
			numberOfExposures: Int(self.store.summary?.summary.matchedKeyCount ?? 0),
			activeTracing: tracingHistory.activeTracing(),
			exposureDetectionDate: self.store.summary?.date
		)

		// Risk Calculation involves some potentially long running tasks, like exposure detection and
		// fetching the configuration from the backend.
		// However in some precondition cases we can return early, mainly:
		// 1. The exposureManagerState is bad (turned off, not authorized, etc.)
		// 2. Tracing has not been active for at least 24 hours
		guard self.exposureManagerState.isGood else {
			Log.info("RiskProvider: Precondition not met for ExposureManagerState", log: .riskDetection)
			return Risk(
				level: .inactive,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		guard numberOfEnabledHours >= TracingStatusHistory.minimumActiveHours else {
			Log.info("RiskProvider: Precondition not met for minimumActiveHours", log: .riskDetection)
			return Risk(
				level: .unknownInitial,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		return nil
	}

	private func determineSummary(
		userInitiated: Bool,
		ignoreCachedSummary: Bool = false,
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping (Result<SummaryMetadata, RiskProviderError>) -> Void
	) {
		if shouldLoadSummaryFromCache(userInitiated: userInitiated, ignoreCachedSummary: ignoreCachedSummary),
		   let cachedSummary = store.summary {
			Log.info("RiskProvider: Loaded summary from cache", log: .riskDetection)
			completion(.success(cachedSummary))
		} else {
			executeExposureDetection(appConfiguration: appConfiguration, completion: completion)
		}
	}

	private func shouldLoadSummaryFromCache(
		userInitiated: Bool,
		ignoreCachedSummary: Bool = false
	) -> Bool {

		guard !ignoreCachedSummary else {
			return true
		}

		// Here we are in automatic mode and thus we have to check the validity of the current summary.
		let enoughTimeHasPassed = riskProvidingConfiguration.shouldPerformExposureDetection(
			activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
			lastExposureDetectionDate: store.summary?.date
		)

		let config = riskProvidingConfiguration
		let shouldDetectExposures = (config.detectionMode == .manual && userInitiated) || config.detectionMode == .automatic
		
		/// If the User is in manual mode and wants to refresh we should let him. Case: Manual Mode and Wifi disabled will lead to no new packages in the last 23 hours and 59 Minutes, but a refresh interval of 4 Hours should allow this.
		let shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = shouldDetectExposureBecauseOfNewPackages || (config.detectionMode == .manual && userInitiated)
		
		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: enoughTimeHasPassed = \(enoughTimeHasPassed)", log: .riskDetection)
		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: exposureManagerState.isGood = \(exposureManagerState.isGood)", log: .riskDetection)
		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposures = \(shouldDetectExposures)", log: .riskDetection)
		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = \(shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode)", log: .riskDetection)
		
		return !(enoughTimeHasPassed && exposureManagerState.isGood && shouldDetectExposures && shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode)
	}

	private var shouldDetectExposureBecauseOfNewPackages: Bool {
		let lastKeyPackageDownloadDate = store.lastKeyPackageDownloadDate
		let lastExposureDetectionDate = store.summary?.date ?? .distantPast
		let didDownloadNewPackagesSinceLastDetection = lastKeyPackageDownloadDate > lastExposureDetectionDate
		let hoursSinceLastDetection = -lastExposureDetectionDate.hoursSinceNow
		let lastDetectionMoreThan24HoursAgo = hoursSinceLastDetection > 24

		return didDownloadNewPackagesSinceLastDetection || lastDetectionMoreThan24HoursAgo
	}

	private func executeExposureDetection(
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping (Result<SummaryMetadata, RiskProviderError>) -> Void
	) {
		self.updateActivityState(.detecting)

		
		// The summary is outdated: do a exposure detection
		let _exposureDetection = ExposureDetection(
			delegate: exposureDetectionExecutor,
			appConfiguration: appConfiguration,
			deviceTimeCheck: DeviceTimeCheck(store: store)
		)

		_exposureDetection.start { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let detectedSummary):
				Log.info("RiskProvider: Detect exposure completed", log: .riskDetection)

				let summary = SummaryMetadata(detectionSummary: detectedSummary, date: Date())
				self.store.summary = summary

				/// We were able to calculate a risk so we have to reset the deadman notification
				UNUserNotificationCenter.current().resetDeadmanNotification()
				completion(.success(summary))
			case .failure(let error):
				Log.error("RiskProvider: Detect exposure failed", log: .riskDetection, error: error)

				completion(.failure(.failedRiskDetection(error)))
			}
		}

		self.exposureDetection = _exposureDetection
	}

	private func calculateRiskLevel(summary: SummaryMetadata?, appConfiguration: SAP_Internal_ApplicationConfiguration, completion: Completion?) {
		Log.info("RiskProvider: Calculate risk level", log: .riskDetection)

		let activeTracing = store.tracingStatusHistory.activeTracing()

		guard
			let risk = riskCalculation.risk(
				summary: summary?.summary,
				configuration: appConfiguration,
				dateLastExposureDetection: summary?.date,
				activeTracing: activeTracing,
				preconditions: exposureManagerState,
				previousRiskLevel: store.previousRiskLevel,
				providerConfiguration: riskProvidingConfiguration
			) else {
			Log.error("Serious error during risk calculation", log: .riskDetection)
			completion?(.failure(.failedRiskCalculation))
			return
		}

		/// Only set shouldShowRiskStatusLoweredAlert if risk level has changed from increase to low or vice versa. Otherwise leave shouldShowRiskStatusLoweredAlert unchanged.
		/// Scenario: Risk level changed from increased to low in the first risk calculation. In a second risk calculation it stays low. If the user does not open the app between these two calculations, the alert should still be shown.
		if risk.riskLevelHasChanged {
			switch risk.level {
			case .low:
				store.shouldShowRiskStatusLoweredAlert = true
			case .increased:
				store.shouldShowRiskStatusLoweredAlert = false
			default:
				break
			}
		}

		completion?(.success(risk))
		savePreviousRiskLevel(risk)

		/// We were able to calculate a risk so we have to reset the DeadMan Notification
		UNUserNotificationCenter.current().resetDeadmanNotification()
	}

	private func _provideRiskResult(_ result: RiskCalculationResult, to consumer: RiskConsumer?) {
		#if DEBUG
		if isUITesting {
			consumer?.provideRiskCalculationResult(.success(.mocked))
			return
		}
		#endif

		consumer?.provideRiskCalculationResult(result)
	}

	private func savePreviousRiskLevel(_ risk: Risk) {
		switch risk.level {
		case .low:
			store.previousRiskLevel = .low
		case .increased:
			store.previousRiskLevel = .increased
		default:
			break
		}
	}

    private func updateRiskProvidingConfiguration(with appConfig: SAP_Internal_ApplicationConfiguration) {
        let maxExposureDetectionsPerInterval = Int(appConfig.iosExposureDetectionParameters.maxExposureDetectionsPerInterval)

        var exposureDetectionInterval: DateComponents
        if maxExposureDetectionsPerInterval == 0 {
            // Deactivate exposure detection by setting a high, not reachable value.
			// Int.max does not work. It leads to DateComponents.hour == nil.
            exposureDetectionInterval = DateComponents(hour: Int.max.advanced(by: -1)) // a.k.a. 1 BER build
        } else {
            exposureDetectionInterval = DateComponents(hour: 24 / maxExposureDetectionsPerInterval)
        }

        self.riskProvidingConfiguration = RiskProvidingConfiguration(
			exposureDetectionValidityDuration: DateComponents(day: 2),
			exposureDetectionInterval: exposureDetectionInterval,
			detectionMode: riskProvidingConfiguration.detectionMode
		)
    }

	private func updateActivityState(_ state: ActivityState) {
		Log.info("RiskProvider: Update activity state to: \(state)", log: .riskDetection)

		self.activityState = state

		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeActivityState?(state)
			}
		}
	}

	private func registerForPackageDownloadStatusUpdate() {
		self.keyPackageDownload.statusDidChange = { [weak self] downloadStatus in
			guard let self = self else { return }

			switch downloadStatus {
			case .downloading:
				self.updateActivityState(.downloading)
			default:
				break
			}
		}
	}
}

extension RiskProvider {
	enum ActivityState {
		case idle
		case riskRequested
		case downloading
		case detecting

		var isActive: Bool {
			self == .downloading || self == .detecting
		}
	}
}

#if DEBUG
extension RiskProvider {
	private func _requestRiskLevel_Mock(userInitiated: Bool, completion: Completion? = nil) {
		let risk = Risk.mocked
		successOnTargetQueue(risk: risk, completion: completion)

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}

		savePreviousRiskLevel(risk)
	}
}
#endif
