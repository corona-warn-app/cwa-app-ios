////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeState: ENStateHandlerUpdating {

	// MARK: - Init

	init(
		store: Store,
		riskProvider: RiskProviding,
		exposureManagerState: ExposureManagerState,
		enState: ENStateHandler.State,
		exposureSubmissionService: ExposureSubmissionService,
		statisticsProvider: StatisticsProviding
	) {
		if let riskCalculationResult = store.riskCalculationResult,
		   let checkinCalculationResult = store.checkinRiskCalculationResult {
			self.riskState = .risk(
				Risk(
					riskCalculationResult: riskCalculationResult,
					checkinCalculationResult: checkinCalculationResult
				)
			)
		} else {
			self.riskState = .risk(
				Risk(
					level: .low,
					details: .init(
						mostRecentDateWithRiskLevel: nil,
						numberOfDaysWithRiskLevel: 0,
						exposureDetectionDate: nil
					),
					riskLevelHasChanged: false
				)
			)
		}

		self.store = store
		self.riskProvider = riskProvider
		self.exposureManagerState = exposureManagerState
		self.enState = enState
		self.exposureSubmissionService = exposureSubmissionService
		self.statisticsProvider = statisticsProvider

		self.exposureDetectionInterval = riskProvider.riskProvidingConfiguration.exposureDetectionInterval.hour ?? RiskProvidingConfiguration.defaultExposureDetectionsInterval

		observeRisk()
	}

	// MARK: - Protocol ENStateHandlerUpdating

	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
	}

	// MARK: - Internal

	enum TestResultLoadingError {
		case expired
		case error(Error)
	}

	enum StatisticsLoadingError {
		case dataVerificationError
	}

	@OpenCombine.Published var riskState: RiskState
	@OpenCombine.Published var riskProviderActivityState: RiskProviderActivityState = .idle
	@OpenCombine.Published private(set) var detectionMode: DetectionMode = .fromBackgroundStatus()
	@OpenCombine.Published private(set) var exposureManagerState: ExposureManagerState
	@OpenCombine.Published var enState: ENStateHandler.State

	@OpenCombine.Published var testResult: TestResult?
	@OpenCombine.Published var testResultIsLoading: Bool = false
	@OpenCombine.Published var testResultLoadingError: TestResultLoadingError?

	@OpenCombine.Published var statistics: SAP_Internal_Stats_Statistics = SAP_Internal_Stats_Statistics()
	@OpenCombine.Published var statisticsLoadingError: StatisticsLoadingError?

	@OpenCombine.Published private(set) var exposureDetectionInterval: Int

	var manualExposureDetectionState: ManualExposureDetectionState? {
		riskProvider.manualExposureDetectionState
	}

	var lastRiskCalculationResult: RiskCalculationResult? {
		store.riskCalculationResult
	}

	var nextExposureDetectionDate: Date {
		riskProvider.nextExposureDetectionDate
	}

	var positiveTestResultWasShown: Bool {
		store.registrationToken != nil && testResult == .positive && WarnOthersReminder(store: store).positiveTestResultWasShown
	}

	var keysWereSubmitted: Bool {
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp != nil
	}

	var shouldShowDaysSinceInstallation: Bool {
		daysSinceInstallation < 14
	}

	var daysSinceInstallation: Int {
		store.appInstallationDate?.ageInDays ?? 0
	}

	func updateDetectionMode(_ detectionMode: DetectionMode) {
		self.detectionMode = detectionMode
	}

	func updateExposureManagerState(_ exposureManagerState: ExposureManagerState) {
		self.exposureManagerState = exposureManagerState
	}

	func requestRisk(userInitiated: Bool) {
		riskProvider.requestRisk(userInitiated: userInitiated)
	}

	func updateTestResult() {
		// Avoid unnecessary loading.
		guard testResult == nil || testResult != .positive else { return }

		guard store.registrationToken != nil else {
			testResult = nil
			return
		}

		// Make sure to make the loading cell appear for at least `minRequestTime`.
		// This avoids an ugly flickering when the cell is only shown for the fraction of a second.
		// Make sure to only trigger this additional delay when no other test result is present already.
		let requestStart = Date()
		let minRequestTime: TimeInterval = 0.5

		testResultIsLoading = true

		exposureSubmissionService.getTestResult { [weak self] result in
			self?.testResultIsLoading = false

			switch result {
			case .failure(let error):
				// When we fail here, publish the error to trigger an alert and set the state to pending.
				self?.testResultLoadingError = .error(error)
				self?.testResult = .pending

			case .success(let testResult):
				switch testResult {
				case .expired:
					self?.testResultLoadingError = .expired
					self?.testResult = .expired

				case .invalid, .negative, .positive, .pending:
					let requestTime = Date().timeIntervalSince(requestStart)
					let delay = requestTime < minRequestTime && self?.testResult == nil ? minRequestTime : 0
					DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
						self?.testResult = testResult
					}
				}
			}
		}
	}

	func updateStatistics() {
		statisticsProvider.statistics()
			.sink(
				receiveCompletion: { [weak self] result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						// Propagate signature verification error to the user
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							self?.statisticsLoadingError = .dataVerificationError
						}
						Log.error("[HomeState] Could not load statistics: \(error)", log: .api)
					}
				}, receiveValue: { [weak self] in
					self?.statistics = $0
				}
			)
			.store(in: &subscriptions)
	}

	// MARK: - Private

	private let store: Store

	private let statisticsProvider: StatisticsProviding
	private var subscriptions = Set<AnyCancellable>()

	private let exposureSubmissionService: ExposureSubmissionService

	private let riskProvider: RiskProviding
	private let riskConsumer = RiskConsumer()

	private func observeRisk() {
		riskConsumer.didChangeActivityState = { [weak self] state in
			self?.riskProviderActivityState = state
		}

		riskConsumer.didCalculateRisk = { [weak self] risk in
			self?.riskState = .risk(risk)
		}

		riskConsumer.didFailCalculateRisk = { [weak self] error in
			guard let self = self else { return }

			// Don't show already running errors.
			guard !error.isAlreadyRunningError else {
				Log.info("[HomeTableViewModel.State] Ignore already running error.", log: .riskDetection)
				return
			}

			guard error.shouldBeDisplayedToUser else {
				Log.info("[HomeTableViewModel.State] Don't show error to user: \(error).", log: .riskDetection)
				return
			}

			switch error {
			case .inactive:
				self.riskState = .inactive
			default:
				self.riskState = .detectionFailed
			}
		}

		riskConsumer.didChangeRiskProvidingConfiguration = { [weak self] configuration in
			guard let interval = configuration.exposureDetectionInterval.hour else { return }
			self?.exposureDetectionInterval = interval
		}

		riskProvider.observeRisk(riskConsumer)
	}

}
