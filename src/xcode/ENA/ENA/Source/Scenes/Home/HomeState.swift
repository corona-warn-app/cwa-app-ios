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
		exposureSubmissionService: ExposureSubmissionService
	) {
		if let riskCalculationResult = store.riskCalculationResult {
			self.riskState = .risk(
				Risk(
					activeTracing: store.tracingStatusHistory.activeTracing(),
					riskCalculationResult: riskCalculationResult
				)
			)
		} else {
			self.riskState = .risk(
				Risk(
					level: .low,
					details: .init(
						mostRecentDateWithRiskLevel: nil,
						numberOfDaysWithRiskLevel: 0,
						activeTracing: store.tracingStatusHistory.activeTracing(),
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

	let store: Store

	@OpenCombine.Published private(set) var riskState: RiskState
	@OpenCombine.Published private(set) var riskProviderActivityState: RiskProviderActivityState = .idle
	@OpenCombine.Published private(set) var detectionMode: DetectionMode = .fromBackgroundStatus()
	@OpenCombine.Published private(set) var exposureManagerState: ExposureManagerState
	@OpenCombine.Published private(set) var enState: ENStateHandler.State

	@OpenCombine.Published private(set) var testResult: TestResult?
	@OpenCombine.Published private(set) var testResultIsLoading: Bool = false
	@OpenCombine.Published var testResultLoadingError: TestResultLoadingError?

	@OpenCombine.Published private(set) var statistics: SAP_Internal_Stats_Statistics = SAP_Internal_Stats_Statistics()

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

		// Infections

		var card1Header = SAP_Internal_Stats_CardHeader()
		card1Header.cardID = 1
		card1Header.updatedAt = Int64(Date(timeIntervalSinceNow: -72 * 60 * 60).timeIntervalSince1970)

		var card1Figure1 = SAP_Internal_Stats_KeyFigure()
		card1Figure1.rank = .primary
		card1Figure1.value = 9_999_999
		card1Figure1.decimals = 0
		card1Figure1.trend = .unspecifiedTrend
		card1Figure1.trendSemantic = .unspecifiedTrendSemantic

		var card1Figure2 = SAP_Internal_Stats_KeyFigure()
		card1Figure2.rank = .secondary
		card1Figure2.value = 10_000_000
		card1Figure2.decimals = 0
		card1Figure2.trend = .stable
		card1Figure2.trendSemantic = .positive

		var card1Figure3 = SAP_Internal_Stats_KeyFigure()
		card1Figure3.rank = .tertiary
		card1Figure3.value = 10_050_001
		card1Figure3.decimals = 0
		card1Figure3.trend = .unspecifiedTrend
		card1Figure3.trendSemantic = .unspecifiedTrendSemantic

		var card1 = SAP_Internal_Stats_KeyFigureCard()
		card1.header = card1Header
		card1.keyFigures = [card1Figure1, card1Figure2, card1Figure3]

		// Incidence

		var card2Header = SAP_Internal_Stats_CardHeader()
		card2Header.cardID = 2
		card2Header.updatedAt = Int64(Date(timeIntervalSinceNow: -48 * 60 * 60).timeIntervalSince1970)

		var card2Figure1 = SAP_Internal_Stats_KeyFigure()
		card2Figure1.rank = .primary
		card2Figure1.value = 98.9
		card2Figure1.decimals = 1
		card2Figure1.trend = .increasing
		card2Figure1.trendSemantic = .negative

		var card2 = SAP_Internal_Stats_KeyFigureCard()
		card2.header = card2Header
		card2.keyFigures = [card2Figure1]

		// Key Submissions

		var card3Header = SAP_Internal_Stats_CardHeader()
		card3Header.cardID = 3
		card3Header.updatedAt = Int64(Date(timeIntervalSinceNow: -24 * 60 * 60).timeIntervalSince1970)

		var card3Figure1 = SAP_Internal_Stats_KeyFigure()
		card3Figure1.rank = .primary
		card3Figure1.value = 1514
		card3Figure1.decimals = 0
		card3Figure1.trend = .unspecifiedTrend
		card3Figure1.trendSemantic = .unspecifiedTrendSemantic

		var card3Figure2 = SAP_Internal_Stats_KeyFigure()
		card3Figure2.rank = .secondary
		card3Figure2.value = 1812
		card3Figure2.decimals = 0
		card3Figure2.trend = .decreasing
		card3Figure2.trendSemantic = .neutral

		var card3Figure3 = SAP_Internal_Stats_KeyFigure()
		card3Figure3.rank = .tertiary
		card3Figure3.value = 20922
		card3Figure3.decimals = 0
		card3Figure3.trend = .unspecifiedTrend
		card3Figure3.trendSemantic = .unspecifiedTrendSemantic

		var card3 = SAP_Internal_Stats_KeyFigureCard()
		card3.header = card3Header
		card3.keyFigures = [card3Figure1, card3Figure2, card3Figure3]

		// Reproduction Number

		var card4Header = SAP_Internal_Stats_CardHeader()
		card4Header.cardID = 4
		card4Header.updatedAt = Int64(Date().timeIntervalSince1970)

		var card4Figure1 = SAP_Internal_Stats_KeyFigure()
		card4Figure1.rank = .primary
		card4Figure1.value = 1.04
		card4Figure1.decimals = -2
		card4Figure1.trend = .increasing
		card4Figure1.trendSemantic = .negative

		var card4 = SAP_Internal_Stats_KeyFigureCard()
		card4.header = card4Header
		card4.keyFigures = [card4Figure1]

		//

		var statistics = SAP_Internal_Stats_Statistics()
		statistics.cardIDSequence = [1, 3, 2, 4]
		statistics.keyFigureCards = [card1, card2, card3, card4]

		self.statistics = statistics
	}

	// MARK: - Private

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
