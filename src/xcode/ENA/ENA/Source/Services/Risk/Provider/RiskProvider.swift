//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification
import UIKit
import OpenCombine

final class RiskProvider: RiskProviding {

	// MARK: - Init

	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		riskCalculation: RiskCalculationProtocol = RiskCalculation(),
		keyPackageDownload: KeyPackageDownloadProtocol,
		tracePackageDownload: TraceWarningPackageDownloading,
		exposureDetectionExecutor: ExposureDetectionDelegate
	) {
		self.riskProvidingConfiguration = configuration
		self.store = store
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
		self.riskCalculation = riskCalculation
		self.keyPackageDownload = keyPackageDownload
		self.tracePackageDownload = tracePackageDownload
		self.exposureDetectionExecutor = exposureDetectionExecutor

		self.registerForPackageDownloadStatusUpdate()
	}

	// MARK: - Protocol RiskProviding

	var riskProvidingConfiguration: RiskProvidingConfiguration {
		didSet {
			if riskProvidingConfiguration != oldValue {
				riskProvidingConfigurationChanged(riskProvidingConfiguration)
			}
		}
	}

	var exposureManagerState: ExposureManagerState
	private(set) var activityState: RiskProviderActivityState = .idle

	var manualExposureDetectionState: ManualExposureDetectionState? {
		riskProvidingConfiguration.manualExposureDetectionState(
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate
		)
	}

	/// Returns the next possible date of a exposureDetection
	var nextExposureDetectionDate: Date {
		riskProvidingConfiguration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate
		)
	}

	func observeRisk(_ consumer: RiskConsumer) {
		consumers.insert(consumer)
	}

	func removeRisk(_ consumer: RiskConsumer) {
		consumers.remove(consumer)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk(userInitiated: Bool, timeoutInterval: TimeInterval) {
		#if DEBUG
		if isUITesting {
			self._requestRiskLevel_Mock(userInitiated: userInitiated)
			return
		}
		#endif

		Log.info("RiskProvider: Request risk was called. UserInitiated: \(userInitiated)", log: .riskDetection)

		guard activityState == .idle else {
			Log.info("RiskProvider: Risk detection is already running. Don't start new risk detection.", log: .riskDetection)
			failOnTargetQueue(error: .riskProviderIsRunning, updateState: false)
			return
		}

		guard store.lastSuccessfulSubmitDiagnosisKeyTimestamp == nil else {
			Log.info("RiskProvider: Keys were already submitted. Don't start new risk detection.", log: .riskDetection)

			// Keep downloading key packages for plausible deniability
			downloadKeyPackages()

			return
		}

		guard !WarnOthersReminder(store: store).positiveTestResultWasShown else {
			Log.info("RiskProvider: Positive test result was already shown. Don't start new risk detection.", log: .riskDetection)

			// Keep downloading key packages for plausible deniability
			downloadKeyPackages()

			return
		}

		queue.async {
			self.updateActivityState(.riskRequested)
			self._requestRiskLevel(userInitiated: userInitiated, timeoutInterval: timeoutInterval)
		}
	}

	// MARK: - Private
    private typealias Completion = (RiskProviderResult) -> Void

	private let store: Store
	private let appConfigurationProvider: AppConfigurationProviding
	private let targetQueue: DispatchQueue
	private let riskCalculation: RiskCalculationProtocol
	private let exposureDetectionExecutor: ExposureDetectionDelegate
	private let tracePackageDownload: TraceWarningPackageDownloading
	
	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")

	private var keyPackageDownload: KeyPackageDownloadProtocol
	private var exposureDetection: ExposureDetection?
	private var subscriptions = [AnyCancellable]()
	
	private var _consumers: Set<RiskConsumer> = Set<RiskConsumer>()
	private var consumers: Set<RiskConsumer> {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	private var shouldDetectExposureBecauseOfNewPackages: Bool {
		let lastKeyPackageDownloadDate = store.lastKeyPackageDownloadDate
		let lastExposureDetectionDate = store.riskCalculationResult?.calculationDate ?? .distantPast
		let didDownloadNewPackagesSinceLastDetection = lastKeyPackageDownloadDate > lastExposureDetectionDate
		let hoursSinceLastDetection = -lastExposureDetectionDate.hoursSinceNow
		let lastDetectionMoreThan24HoursAgo = hoursSinceLastDetection > 24

		return didDownloadNewPackagesSinceLastDetection || lastDetectionMoreThan24HoursAgo
	}

	private func _requestRiskLevel(userInitiated: Bool, timeoutInterval: TimeInterval) {
		let group = DispatchGroup()
		group.enter()
		appConfigurationProvider.appConfiguration().sink { [weak self] appConfiguration in
			guard let self = self else { return }
			
			self.updateRiskProvidingConfiguration(with: appConfiguration)
			
			self.downloadKeyPackages { result in
				switch result {
				case .success:
					self.determineRisk(
						userInitiated: userInitiated,
						appConfiguration: appConfiguration
					) { result in
						
						switch result {
						case .success(let risk):
							self.successOnTargetQueue(risk: risk)
						case .failure(let error):
							self.failOnTargetQueue(error: error)
						}
						group.leave()
					}
				case .failure(let error):
					self.failOnTargetQueue(error: error)
					group.leave()
				}
			}
		}.store(in: &subscriptions)

		guard group.wait(timeout: DispatchTime.now() + timeoutInterval) == .success else {
			updateActivityState(.idle)
			exposureDetection?.cancel()
			Log.info("RiskProvider: Canceled risk calculation due to timeout", log: .riskDetection)
			failOnTargetQueue(error: .timeout)
			return
		}
	}

	private func downloadKeyPackages(completion: ((Result<Void, RiskProviderError>) -> Void)? = nil) {
		// The result of a hour package download is not handled, because for the risk detection it is irrelevant if it fails or not.
		self.downloadHourPackages { [weak self] in
			guard let self = self else { return }

			self.downloadDayPackages(completion: { result in
				completion?(result)
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
		appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping Completion
	) {
		// Risk Calculation involves some potentially long running tasks, like exposure detection and
		// fetching the configuration from the backend.
		// However in some precondition cases we can return early:
		// 1. The exposureManagerState is bad (turned off, not authorized, etc.)
		if !exposureManagerState.isGood {
			Log.info("RiskProvider: Precondition not met for ExposureManagerState", log: .riskDetection)
			completion(.failure(.inactive))
			return
		}

		// 2. There is a previous risk that is still valid and should not be recalculated
		if let risk = previousRiskIfExistingAndNotExpired(userInitiated: userInitiated) {
			Log.info("RiskProvider: Using risk from previous detection", log: .riskDetection)
			completion(.success(risk))
			return
		}

		executeExposureDetection(
			appConfiguration: appConfiguration,
			completion: { [weak self] result in
				guard let self = self else { return }

				switch result {
				case .success(let exposureWindows):
					self.calculateRiskLevel(
						exposureWindows: exposureWindows,
						appConfiguration: appConfiguration,
						completion: completion
					)
				case .failure(let error):
					completion(.failure(error))
				}
			}
		)
	}

	private func previousRiskIfExistingAndNotExpired(userInitiated: Bool) -> Risk? {
		let enoughTimeHasPassed = riskProvidingConfiguration.shouldPerformExposureDetection(
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate
		)
		let shouldDetectExposures = (riskProvidingConfiguration.detectionMode == .manual && userInitiated) || riskProvidingConfiguration.detectionMode == .automatic

		// If the User is in manual mode and wants to refresh we should let him. Case: Manual Mode and Wifi disabled will lead to no new packages in the last 23 hours and 59 Minutes, but a refresh interval of 4 Hours should allow this.
		let shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = shouldDetectExposureBecauseOfNewPackages || (riskProvidingConfiguration.detectionMode == .manual && userInitiated)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: enoughTimeHasPassed = \(enoughTimeHasPassed)", log: .riskDetection)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposures = \(shouldDetectExposures)", log: .riskDetection)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = \(shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode)", log: .riskDetection)
		
		if !enoughTimeHasPassed || !shouldDetectExposures || !shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode,
		   let riskCalculationResult = store.riskCalculationResult {
			Log.info("RiskProvider: Not calculating new risk, using result of most recent risk calculation", log: .riskDetection)
			return Risk(riskCalculationResult: riskCalculationResult)
		}

		return nil
	}

	private func executeExposureDetection(
		appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping (Result<[ExposureWindow], RiskProviderError>) -> Void
	) {
		self.updateActivityState(.detecting)

		let _exposureDetection = ExposureDetection(
			delegate: exposureDetectionExecutor,
			appConfiguration: appConfiguration,
			deviceTimeCheck: DeviceTimeCheck(store: store)
		)

		_exposureDetection.start { result in
			switch result {
			case .success(let detectedExposureWindows):
				Log.info("RiskProvider: Detect exposure completed", log: .riskDetection)

				let exposureWindows = detectedExposureWindows.map { ExposureWindow(from: $0) }
				completion(.success(exposureWindows))
			case .failure(let error):
				Log.error("RiskProvider: Detect exposure failed", log: .riskDetection, error: error)

				completion(.failure(.failedRiskDetection(error)))
			}
		}

		self.exposureDetection = _exposureDetection
	}

	private func calculateRiskLevel(exposureWindows: [ExposureWindow], appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS, completion: Completion) {
		Log.info("RiskProvider: Calculate risk level", log: .riskDetection)

		let configuration = RiskCalculationConfiguration(from: appConfiguration.riskCalculationParameters)


			let riskCalculationResult = riskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)
			let mappedWindows = exposureWindows.map { RiskCalculationExposureWindow(exposureWindow: $0, configuration: configuration) }
			Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedWindows)))
			let risk = Risk(
				riskCalculationResult: riskCalculationResult,
				previousRiskCalculationResult: store.riskCalculationResult
			)

			store.riskCalculationResult = riskCalculationResult
			checkIfRiskStatusLoweredAlertShouldBeShown(risk)
			Analytics.collect(.riskExposureMetadata(.updateRiskExposureMetadata(riskCalculationResult)))

			completion(.success(risk))

			/// We were able to calculate a risk so we have to reset the DeadMan Notification
			DeadmanNotificationManager(store: store).resetDeadmanNotification()
	}
	

	private func _provideRiskResult(_ result: RiskProviderResult, to consumer: RiskConsumer?) {
		#if DEBUG
		if isUITesting && UserDefaults.standard.string(forKey: "riskLevel") == "inactive" {
			consumer?.provideRiskCalculationResult(.failure(.inactive))
			return
		}
		#endif
		
		consumer?.provideRiskCalculationResult(result)
	}

	private func checkIfRiskStatusLoweredAlertShouldBeShown(_ risk: Risk) {
		/// Only set shouldShowRiskStatusLoweredAlert if risk level has changed from increase to low or vice versa. Otherwise leave shouldShowRiskStatusLoweredAlert unchanged.
		/// Scenario: Risk level changed from high to low in the first risk calculation. In a second risk calculation it stays low. If the user does not open the app between these two calculations, the alert should still be shown.
		if risk.riskLevelHasChanged {
			switch risk.level {
			case .low:
				store.shouldShowRiskStatusLoweredAlert = true
			case .high:
				store.shouldShowRiskStatusLoweredAlert = false
				store.dateOfConversionToHighRisk = Date()
			}
		}
	}

    private func updateRiskProvidingConfiguration(with appConfig: SAP_Internal_V2_ApplicationConfigurationIOS) {
        let maxExposureDetectionsPerInterval = Int(appConfig.exposureDetectionParameters.maxExposureDetectionsPerInterval)

        var exposureDetectionInterval: DateComponents
        if maxExposureDetectionsPerInterval <= 0 {
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

	private func successOnTargetQueue(risk: Risk) {
		Log.info("RiskProvider: Risk detection and calculation was successful.", log: .riskDetection)

		updateActivityState(.idle)

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}
	}

	private func failOnTargetQueue(error: RiskProviderError, updateState: Bool = true) {
		Log.info("RiskProvider: Failed with error: \(error)", log: .riskDetection)
		
		if updateState {
			updateActivityState(.idle)
		}

		for consumer in consumers {
			_provideRiskResult(.failure(error), to: consumer)
		}
	}

	private func updateActivityState(_ state: RiskProviderActivityState) {
		Log.info("RiskProvider: Update activity state to: \(state)", log: .riskDetection)

		self.activityState = state

		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeActivityState?(state)
			}
		}
	}

	private func riskProvidingConfigurationChanged(_ configuration: RiskProvidingConfiguration) {
		Log.info("RiskProvider: Inform consumers about risk providing configuration change to: \(configuration)", log: .riskDetection)

		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeRiskProvidingConfiguration?(configuration)
			}
		}
	}

	private func registerForPackageDownloadStatusUpdate() {
		self.keyPackageDownload.statusDidChange = { [weak self] downloadStatus in
			guard let self = self else { return }

			switch downloadStatus {
			case .downloading:
				self.updateActivityState(.downloading)
			/// In end-of-life state we only download the keys, therefore the activity state needs to be reset to idle when the download is finished
			case .idle where self.store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil || WarnOthersReminder(store: self.store).positiveTestResultWasShown:
				self.updateActivityState(.idle)
			default:
				break
			}
		}
	}
}

private extension RiskConsumer {
	func provideRiskCalculationResult(_ result: RiskProviderResult) {
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

#if DEBUG
extension RiskProvider {
	private func _requestRiskLevel_Mock(userInitiated: Bool) {
		let risk = Risk.mocked

		let dateFormatter = ISO8601DateFormatter.contactDiaryUTCFormatter
		let todayString = dateFormatter.string(from: Date())
		guard let today = dateFormatter.date(from: todayString),
			  let someDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today) else {
			fatalError("Could not create date test data for riskLevelPerDate.")
		}

		switch risk.level {
		case .high:
			store.riskCalculationResult = RiskCalculationResult(
				riskLevel: .high,
				minimumDistinctEncountersWithLowRisk: 0,
				minimumDistinctEncountersWithHighRisk: 0,
				mostRecentDateWithLowRisk: risk.details.mostRecentDateWithRiskLevel,
				mostRecentDateWithHighRisk: risk.details.mostRecentDateWithRiskLevel,
				numberOfDaysWithLowRisk: risk.details.numberOfDaysWithRiskLevel,
				numberOfDaysWithHighRisk: risk.details.numberOfDaysWithRiskLevel,
				calculationDate: Date(),
				riskLevelPerDate: [
					today: .high,
					someDaysAgo: .low
				],
				minimumDistinctEncountersWithHighRiskPerDate: [
					today: 1,
					someDaysAgo: 1
				]
			)
		default:
			store.riskCalculationResult = RiskCalculationResult(
				riskLevel: .low,
				minimumDistinctEncountersWithLowRisk: 0,
				minimumDistinctEncountersWithHighRisk: 0,
				mostRecentDateWithLowRisk: risk.details.mostRecentDateWithRiskLevel,
				mostRecentDateWithHighRisk: risk.details.mostRecentDateWithRiskLevel,
				numberOfDaysWithLowRisk: risk.details.numberOfDaysWithRiskLevel,
				numberOfDaysWithHighRisk: 0,
				calculationDate: Date(),
				riskLevelPerDate: [
					today: .low,
					someDaysAgo: .low
				],
				minimumDistinctEncountersWithHighRiskPerDate: [
					today: 1,
					someDaysAgo: 1
				]
			)
		}
		successOnTargetQueue(risk: risk)
	}
}
#endif
