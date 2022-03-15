//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import UIKit
import OpenCombine

// swiftlint:disable:next type_body_length
final class RiskProvider: RiskProviding {

	// MARK: - Init

	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		enfRiskCalculation: ENFRiskCalculationProtocol = ENFRiskCalculation(),
		checkinRiskCalculation: CheckinRiskCalculationProtocol,
		keyPackageDownload: KeyPackageDownloadProtocol,
		traceWarningPackageDownload: TraceWarningPackageDownloading,
		exposureDetectionExecutor: ExposureDetectionDelegate,
		coronaTestService: CoronaTestServiceProviding
	) {
		self.riskProvidingConfiguration = configuration
		self.store = store
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
		self.enfRiskCalculation = enfRiskCalculation
		self.checkinRiskCalculation = checkinRiskCalculation
		self.keyPackageDownload = keyPackageDownload
		self.traceWarningPackageDownload = traceWarningPackageDownload
		self.exposureDetectionExecutor = exposureDetectionExecutor
		self.coronaTestService = coronaTestService
		self.keyPackageDownloadStatus = .idle
		self.traceWarningDownloadStatus = .idle
		self.rateLimitLogger = RateLimitLogger(store: store)

		self.registerForPackagesDownloadStatusUpdates()
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
			lastExposureDetectionDate: riskCalculationDate
		)
	}

	/// Returns the next possible date of a exposureDetection
	var nextExposureDetectionDate: Date {
		riskProvidingConfiguration.nextExposureDetectionDate(
			lastExposureDetectionDate: riskCalculationDate
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

		guard !coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest else {
			Log.info("RiskProvider: At least one registered test has an already shown positive test result or keys submitted. Don't start new risk detection.", log: .riskDetection)

			// Keep downloading key packages and trace warning packages for plausible deniability
			updateActivityState(.onlyDownloadsRequested)

			downloadKeyPackages { [weak self] result in
				guard let self = self else {
					return
				}
				
				switch result {
				case .success:
					self.appConfigurationProvider.appConfiguration().sink { appConfiguration in
						self.downloadTraceWarningPackages(with: appConfiguration) { result in
							self.updateActivityState(.idle)

							// Check that the shown positive or submitted test wasn't deleted in the meantime.
							// If it was deleted, start a new risk detection.
							guard self.coronaTestService.hasAtLeastOneShownPositiveOrSubmittedTest else {
								self.requestRisk(userInitiated: userInitiated, timeoutInterval: timeoutInterval)
								return
							}

							switch result {
							case .success:
								// Try to obtain already calculated risk.
								if let risk = self.previousRiskIfExistingAndNotExpired(userInitiated: userInitiated) {
									Log.info("RiskProvider: Using risk from previous detection", log: .riskDetection)

									self.successOnTargetQueue(risk: risk)
								} else {
									self.failOnTargetQueue(error: .deactivatedDueToActiveTest)
								}
							case .failure(let error):
								self.failOnTargetQueue(error: error)
							}
						}
					}.store(in: &self.subscriptions)
				case .failure(let error):
					Log.info("RiskProvider: Failed to download key packages", log: .riskDetection)
					self.failOnTargetQueue(error: error)
				}
			}

			return
		}

		queue.async {
			self.updateActivityState(userInitiated ? .riskManuallyRequested : .riskRequested)
			self._requestRiskLevel(userInitiated: userInitiated, timeoutInterval: timeoutInterval)
		}
	}

	// MARK: - Private
	
    private typealias Completion = (RiskProviderResult) -> Void

	private let store: Store
	private let appConfigurationProvider: AppConfigurationProviding
	private let targetQueue: DispatchQueue
	private let enfRiskCalculation: ENFRiskCalculationProtocol
	private let checkinRiskCalculation: CheckinRiskCalculationProtocol
	private let exposureDetectionExecutor: ExposureDetectionDelegate
	private let coronaTestService: CoronaTestServiceProviding
	
	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")

	private var keyPackageDownload: KeyPackageDownloadProtocol
	private var traceWarningPackageDownload: TraceWarningPackageDownloading

	private var exposureDetection: ExposureDetection?
	private var subscriptions = [AnyCancellable]()
	private var keyPackageDownloadStatus: KeyPackageDownloadStatus
	private var traceWarningDownloadStatus: TraceWarningDownloadStatus
	private var rateLimitLogger: RateLimitLogger
	
	private var _consumers: Set<RiskConsumer> = Set<RiskConsumer>()
	private var consumers: Set<RiskConsumer> {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	private var previousRisk: Risk? {
		guard let enfRiskCalculationResult = store.enfRiskCalculationResult,
			  let checkinRiskCalculationResult = store.checkinRiskCalculationResult else {
				  return nil
			  }
		 return Risk(
			 enfRiskCalculationResult: enfRiskCalculationResult,
			 checkinCalculationResult: checkinRiskCalculationResult
		 )
	}

	private var riskCalculationDate: Date? {
		if let enfRiskCalculationResult = store.enfRiskCalculationResult,
		   let checkinRiskCalculationResult = store.checkinRiskCalculationResult {
			let risk = Risk(enfRiskCalculationResult: enfRiskCalculationResult, checkinCalculationResult: checkinRiskCalculationResult)
			return risk.details.calculationDate
		} else {
			return nil
		}
	}

	private var shouldDetectExposureBecauseOfNewPackages: Bool {
		let lastKeyPackageDownloadDate = store.lastKeyPackageDownloadDate
		let lastExposureDetectionDate = store.enfRiskCalculationResult?.calculationDate ?? .distantPast
		let didDownloadNewPackagesSinceLastDetection = lastKeyPackageDownloadDate > lastExposureDetectionDate
		let hoursSinceLastDetection = -lastExposureDetectionDate.hoursSinceNow
		let lastDetectionMoreThan24HoursAgo = hoursSinceLastDetection > 24

		return didDownloadNewPackagesSinceLastDetection || lastDetectionMoreThan24HoursAgo
	}

	private func _requestRiskLevel(userInitiated: Bool, timeoutInterval: TimeInterval) {
		let group = DispatchGroup()
		group.enter()
		appConfigurationProvider
			.appConfiguration()
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] appConfiguration in
				guard let self = self else {
					Log.error("RiskProvider: Error at creating self. Cancel download packages and calculate risk.", log: .riskDetection)
					return
				}

				self.updateRiskProvidingConfiguration(with: appConfiguration)

				// First, download the diagnosis keys
				self.downloadKeyPackages { result in
					switch result {
					case .success:
						// If key download succeeds, continue with the download of the trace warning packages
						self.downloadTraceWarningPackages(with: appConfiguration, completion: { result in
							switch result {
							case .success:
								// And only if both downloads succeeds, we can determine a risk.
								self.determineRisk(userInitiated: userInitiated, appConfiguration: appConfiguration) { result in
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
						})
					case .failure(let error):
						self.failOnTargetQueue(error: error)
						group.leave()
					}
				}
			}.store(in: &subscriptions)

		guard group.wait(timeout: DispatchTime.now() + timeoutInterval) == .success else {
			updateActivityState(.idle)
			exposureDetection?.cancel()
			exposureDetection = nil
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
		keyPackageDownload.startDayPackagesDownload(completion: { [weak self] result in
			switch result {
			case .success:
				completion(.success(()))
			case .failure(let error):
				// we need this delay so the user can see something happened
				self?.targetQueue.asyncAfter(deadline: .now() + 1.0) {
					completion(.failure(.failedKeyPackageDownload(error)))
				}
			}
		})
	}

	private func downloadHourPackages(completion: @escaping () -> Void) {
		keyPackageDownload.startHourPackagesDownload(completion: { _ in
			completion()
		})
	}
	
	private func downloadTraceWarningPackages(
		with appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping (Result<Void, RiskProviderError>) -> Void
	) {
		traceWarningPackageDownload.startTraceWarningPackageDownload(with: appConfiguration, completion: { result in
			switch result {
			case .success:
				completion(.success(()))
			case let .failure(error):
				completion(.failure(.failedTraceWarningPackageDownload(error)))
			}
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
			// update the risk exposure metadatas if new risk calculations are not done in the meanwhile
			Analytics.collect(.riskExposureMetadata(.update))
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
			lastExposureDetectionDate: store.enfRiskCalculationResult?.calculationDate
		)
		let shouldDetectExposures = (riskProvidingConfiguration.detectionMode == .manual && userInitiated) || riskProvidingConfiguration.detectionMode == .automatic

		// If the User is in manual mode and wants to refresh we should let him. Case: Manual Mode and Wifi disabled will lead to no new packages in the last 23 hours and 59 Minutes, but a refresh interval of 4 Hours should allow this.
		let shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = shouldDetectExposureBecauseOfNewPackages || (riskProvidingConfiguration.detectionMode == .manual && userInitiated)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: enoughTimeHasPassed = \(enoughTimeHasPassed)", log: .riskDetection)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposures = \(shouldDetectExposures)", log: .riskDetection)

		Log.info("RiskProvider: Precondition fulfilled for fresh risk detection: shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode = \(shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode)", log: .riskDetection)
		
		if !enoughTimeHasPassed || !shouldDetectExposures || !shouldDetectExposureBecauseOfNewPackagesConsideringDetectionMode,
		   let previousRisk = previousRisk {
			Log.info("RiskProvider: Not calculating new risk, using result of most recent risk calculation", log: .riskDetection)
			return previousRisk
		}

		return nil
	}

	private func executeExposureDetection(
		appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS,
		completion: @escaping (Result<[ExposureWindow], RiskProviderError>) -> Void
	) {
		guard exposureDetection == nil else {
			// in the future someone should debug why this function is called twice in the first place.
			completion(.failure(.riskProviderIsRunning))
			return
		}
		
		self.updateActivityState(.detecting)

		let softBlocking = rateLimitLogger.logBlocking(configuration: riskProvidingConfiguration)
		store.referenceDateForRateLimitLogger = Date()

		exposureDetection = ExposureDetection(
			delegate: exposureDetectionExecutor,
			appConfiguration: appConfiguration,
			deviceTimeCheck: appConfigurationProvider.deviceTimeCheck
		)

		exposureDetection?.start { [weak self] result in
			self?.rateLimitLogger.logEffect(result: result, blocking: softBlocking)
			switch result {
			case .success(let detectedExposureWindows):
				Log.info("RiskProvider: Detect exposure completed", log: .riskDetection)

				let exposureWindows = detectedExposureWindows.map { ExposureWindow(from: $0) }
				completion(.success(exposureWindows))
			case .failure(let error):
				Log.error("RiskProvider: Detect exposure failed", log: .riskDetection, error: error)

				completion(.failure(.failedRiskDetection(error)))
			}
			self?.exposureDetection = nil
		}
	}

	private func calculateRiskLevel(exposureWindows: [ExposureWindow], appConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS, completion: Completion) {
		Log.info("RiskProvider: Calculate risk level", log: .riskDetection)

		let configuration = RiskCalculationConfiguration(from: appConfiguration.riskCalculationParameters)

		let enfRiskCalculationResult = enfRiskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)
		let mappedWindows = exposureWindows.map { RiskCalculationExposureWindow(exposureWindow: $0, configuration: configuration) }
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedWindows)))
		Analytics.collect(.testResultMetadata(.collectCurrentExposureWindows(mappedWindows)))

		let checkinRiskCalculationResult = checkinRiskCalculation.calculateRisk(with: appConfiguration)

		let risk = Risk(
			enfRiskCalculationResult: enfRiskCalculationResult,
			previousENFRiskCalculationResult: store.enfRiskCalculationResult,
			checkinCalculationResult: checkinRiskCalculationResult,
			previousCheckinCalculationResult: store.checkinRiskCalculationResult
		)

		let previousRisk = previousRisk
		store.enfRiskCalculationResult = enfRiskCalculationResult
		store.checkinRiskCalculationResult = checkinRiskCalculationResult

		checkIfRiskLevelHasChangedForNotifications(risk, previousRisk: previousRisk)
		checkIfRiskStatusLoweredAlertShouldBeShown(risk)
		Analytics.collect(.riskExposureMetadata(.update))
		completion(.success(risk))

		/// We were able to calculate a risk so we have to reset the DeadMan Notification
		DeadmanNotificationManager(coronaTestService: coronaTestService).resetDeadmanNotification()
	}

	private func _provideRiskResult(_ result: RiskProviderResult, to consumer: RiskConsumer?) {
		#if DEBUG
		if isUITesting && LaunchArguments.risk.riskLevel.stringValue == "inactive" {
			consumer?.provideRiskCalculationResult(.failure(.inactive))
			return
		}
		#endif
		
		consumer?.provideRiskCalculationResult(result)
	}
	
	private func checkIfRiskLevelHasChangedForNotifications(_ risk: Risk, previousRisk: Risk?) {
		/// Triggers a notification for every risk level change.
		switch risk.riskLevelChange {
		case .decreased:
			Log.info("decrease risk change state won't trigger a high risk notification")
		case .increased:
			triggerHighRiskNotification()
		case let .unchanged(riskLevel):
			guard riskLevel == .high,
				  let mostRecentDateWithRiskLevel = risk.details.mostRecentDateWithRiskLevel,
				  let previousMostRecentDateWithRiskLevel = previousRisk?.details.mostRecentDateWithRiskLevel,
				  mostRecentDateWithRiskLevel > previousMostRecentDateWithRiskLevel
			else {
				Log.info("Missing mostRecentDateWithRiskLevel - do not trigger anything")
				return
			}
			triggerHighRiskNotification()
			// store a flag so we know an alert is required
			switch UIApplication.shared.applicationState {
			case .active:
				Log.info("Another high exposure notification was triggered in foreground - no alert needed")
			case .inactive, .background:
				store.showAnotherHighExposureAlert = true
			@unknown default:
				Log.error("Unknown application state")
			}
		}
	}

	private func triggerHighRiskNotification() {
		Log.info("Trigger notification about high risk level", log: .riskDetection)
		UNUserNotificationCenter.current().presentNotification(
			title: AppStrings.LocalNotifications.detectExposureTitle,
			body: AppStrings.LocalNotifications.detectExposureBody,
			identifier: ActionableNotificationIdentifier.riskDetection.identifier
		)
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

		/// special handling for error 13
		/// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-11706
		///

		if  /// check if error 13 or 16 occurs
			case let .failedRiskDetection(didEndPrematurelyReason) = error,
			case let .noExposureWindows(reason, _) = didEndPrematurelyReason,
			let enError = reason as? ENError,
			enError.code == .rateLimited || enError.code == .dataInaccessible,
			/// only if a previous risk exists we can try to give a fallback
			let previousRisk = previousRisk,
			/// if previous risk is 48h old it's a valid fallback
			let calculationDate = previousRisk.details.calculationDate,
			let validityDate = Calendar.current.date(byAdding: riskProvidingConfiguration.exposureDetectionValidityDuration, to: calculationDate),
			validityDate >= Date() {
			
			Log.error("ENError reached Code: \(enError.code.rawValue) - skip error and use previous risk", log: .riskDetection)
			for consumer in consumers {
				_provideRiskResult(.success(previousRisk), to: consumer)
			}
			return
		}

		for consumer in consumers {
			_provideRiskResult(.failure(error), to: consumer)
		}
	}

	private func updateActivityState(_ state: RiskProviderActivityState) {
		Log.info("RiskProvider: Update activity state to: \(state)", log: .riskDetection)

		guard self.activityState != state else {
			return
		}

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

	private func registerForPackagesDownloadStatusUpdates() {
		keyPackageDownload.statusDidChange = { [weak self] downloadStatus in
			guard let self = self else {
				Log.error("RiskProvider: Error at creating strong self.", log: .riskDetection)
				return
			}
			self.keyPackageDownloadStatus = downloadStatus
			self.updateRiskProviderActivityState()
		}
		
		traceWarningPackageDownload.statusDidChange = { [weak self] downloadStatus in
			guard let self = self else {
				Log.error("RiskProvider: Error at creating strong self.", log: .riskDetection)
				return
			}
			self.traceWarningDownloadStatus = downloadStatus
			self.updateRiskProviderActivityState()
		}
	}
	
	private func updateRiskProviderActivityState() {
		if keyPackageDownloadStatus == .downloading || traceWarningDownloadStatus == .downloading {
			self.updateActivityState(.downloading)
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
		let dateFormatter = ISO8601DateFormatter.justUTCDateFormatter
		let todayString = dateFormatter.string(from: Date())
		guard let today = dateFormatter.date(from: todayString),
			  let someDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today) else {
			fatalError("Could not create date test data for riskLevelPerDate.")
		}
		let calculationDate = Calendar.autoupdatingCurrent.date(bySettingHour: 9, minute: 6, second: 0, of: Date()) ?? Date()
		switch risk.level {
		case .high:
			store.enfRiskCalculationResult = ENFRiskCalculationResult(
				riskLevel: .high,
				minimumDistinctEncountersWithLowRisk: 0,
				minimumDistinctEncountersWithHighRisk: 0,
				mostRecentDateWithLowRisk: risk.details.mostRecentDateWithRiskLevel,
				mostRecentDateWithHighRisk: risk.details.mostRecentDateWithRiskLevel,
				numberOfDaysWithLowRisk: risk.details.numberOfDaysWithRiskLevel,
				numberOfDaysWithHighRisk: risk.details.numberOfDaysWithRiskLevel,
				calculationDate: calculationDate,
				riskLevelPerDate: [
					today: .high,
					someDaysAgo: .low
				],
				minimumDistinctEncountersWithHighRiskPerDate: [
					today: 1,
					someDaysAgo: 1
				]
			)
			store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
				calculationDate: calculationDate,
				checkinIdsWithRiskPerDate: [:],
				riskLevelPerDate: [:]
			)
		default:
			store.enfRiskCalculationResult = ENFRiskCalculationResult(
				riskLevel: .low,
				minimumDistinctEncountersWithLowRisk: 0,
				minimumDistinctEncountersWithHighRisk: 0,
				mostRecentDateWithLowRisk: risk.details.mostRecentDateWithRiskLevel,
				mostRecentDateWithHighRisk: risk.details.mostRecentDateWithRiskLevel,
				numberOfDaysWithLowRisk: risk.details.numberOfDaysWithRiskLevel,
				numberOfDaysWithHighRisk: 0,
				calculationDate: calculationDate,
				riskLevelPerDate: [
					today: .low,
					someDaysAgo: .low
				],
				minimumDistinctEncountersWithHighRiskPerDate: [
					today: 1,
					someDaysAgo: 1
				]
			)
			store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
				calculationDate: calculationDate,
				checkinIdsWithRiskPerDate: [:],
				riskLevelPerDate: [:]
			)
		}
		successOnTargetQueue(risk: risk)
	}
}
// swiftlint:disable:next file_length
#endif
