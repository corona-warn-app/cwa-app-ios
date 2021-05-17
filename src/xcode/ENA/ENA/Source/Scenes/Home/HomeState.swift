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
		statisticsProvider: StatisticsProviding
	) {
		if let riskCalculationResult = store.enfRiskCalculationResult,
		   let checkinCalculationResult = store.checkinRiskCalculationResult {
			self.riskState = .risk(
				Risk(
					enfRiskCalculationResult: riskCalculationResult,
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
						calculationDate: nil
					),
					riskLevelHasChanged: false
				)
			)
		}

		self.store = store
		self.riskProvider = riskProvider
		self.exposureManagerState = exposureManagerState
		self.enState = enState
		self.statisticsProvider = statisticsProvider

		self.exposureDetectionInterval = riskProvider.riskProvidingConfiguration.exposureDetectionInterval.hour ?? RiskProvidingConfiguration.defaultExposureDetectionsInterval

		observeRisk()
	}

	// MARK: - Protocol ENStateHandlerUpdating

	func updateEnState(_ state: ENStateHandler.State) {
		enState = state
	}

	// MARK: - Internal

	enum StatisticsLoadingError {
		case dataVerificationError
	}

	@OpenCombine.Published var riskState: RiskState
	@OpenCombine.Published var riskProviderActivityState: RiskProviderActivityState = .idle
	@OpenCombine.Published private(set) var detectionMode: DetectionMode = .fromBackgroundStatus()
	@OpenCombine.Published private(set) var exposureManagerState: ExposureManagerState
	@OpenCombine.Published var enState: ENStateHandler.State

	@OpenCombine.Published var statistics: SAP_Internal_Stats_Statistics = SAP_Internal_Stats_Statistics()
	@OpenCombine.Published var statisticsLoadingError: StatisticsLoadingError?

	@OpenCombine.Published private(set) var exposureDetectionInterval: Int

	var manualExposureDetectionState: ManualExposureDetectionState? {
		riskProvider.manualExposureDetectionState
	}

	var risk: Risk? {
		guard let enfRiskCalculationResult = store.enfRiskCalculationResult,
			  let checkinRiskCalculationResult = store.checkinRiskCalculationResult else {
			return nil
		}
		return Risk(
			enfRiskCalculationResult: enfRiskCalculationResult,
			checkinCalculationResult: checkinRiskCalculationResult
		)
	}

	var riskCalculationDate: Date? {
		risk?.details.calculationDate
	}

	var nextExposureDetectionDate: Date {
		riskProvider.nextExposureDetectionDate
	}

	var shouldShowDaysSinceInstallation: Bool {
		daysSinceInstallation < 14
	}

	var daysSinceInstallation: Int {
		guard let appInstallationDate = store.appInstallationDate else {
			return 0
		}
		if Calendar.current.isDateInYesterday(appInstallationDate) {
			return 1
		}
		return appInstallationDate.ageInDays ?? 0
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
