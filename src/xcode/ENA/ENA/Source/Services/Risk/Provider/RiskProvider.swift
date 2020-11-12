//
// Corona-Warn-App
//
// SAP SE and all other contributors /
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import ExposureNotification
import UIKit
import Combine

final class RiskProvider {

	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let targetQueue: DispatchQueue
	private var consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")
	private let riskCalculation: RiskCalculationV2Protocol
	private var keyPackageDownload: KeyPackageDownloadProtocol
	private let exposureDetectionExecutor: ExposureDetectionDelegate
	private var exposureDetection: ExposureDetection?

	private var _consumers: [RiskConsumer] = []
	private var consumers: [RiskConsumer] {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		riskCalculation: RiskCalculationV2Protocol = RiskCalculationV2(),
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
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk(userInitiated: Bool, completion: Completion? = nil) {
		Log.info("RiskProvider: Request risk was called. UserInitiated: \(userInitiated)", log: .riskDetection)

		guard activityState == .idle else {
			Log.info("RiskProvider: Risk detection is allready running. Don't start new risk detection", log: .riskDetection)
			targetQueue.async {
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

			self._requestRiskLevel(userInitiated: userInitiated, completion: completion)
		}
	}

	/// Returns the next possible date of a exposureDetection
	/// Case1: Date is a valid date in the future
	/// Case2: Date is in the past (could be .distantPast) (usually happens when no detection has been run before (e.g. fresh install).
	/// For Case2, we need to calculate the remaining time until we reach a full 24h of tracing.
	func nextExposureDetectionDate() -> Date {
		let nextDate = riskProvidingConfiguration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate
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

	private func _requestRiskLevel(userInitiated: Bool, completion: Completion?) {
		let group = DispatchGroup()
		group.enter()

		appConfigurationProvider.appConfiguration { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let appConfiguration):

				self.downloadKeyPackages { [weak self] result in
					guard let self = self else { return }

					switch result {
					case .success:
						self.determineRisk(
							userInitiated: userInitiated,
							appConfiguration: appConfiguration) { result in

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

			case .failure:
				self.failOnTargetQueue(error: .missingAppConfig, completion: completion)
				group.leave()
			}
		}

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
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping (Result<Risk, RiskProviderError>) -> Void
	) {
		if let risk = riskForMissingPreconditions(userInitiated: userInitiated) {
			Log.info("RiskProvider: Determined Risk from preconditions", log: .riskDetection)
			completion(.success(risk))
			return
		}

		self.executeExposureDetection(
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

	private func riskForMissingPreconditions(userInitiated: Bool) -> Risk? {
		let tracingHistory = store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.activeTracing().inHours

		let details = Risk.Details(activeTracing: tracingHistory.activeTracing(), riskCalculationResult: store.riskCalculationResult)

		// Risk Calculation involves some potentially long running tasks, like exposure detection and
		// fetching the configuration from the backend.
		// However in some precondition cases we can return early, mainly:
		// 1. The exposureManagerState is bad (turned off, not authorized, etc.)
		// 2. Tracing has not been active for at least 24 hours
		if !exposureManagerState.isGood {
			Log.info("RiskProvider: Precondition not met for ExposureManagerState", log: .riskDetection)
			return Risk(
				level: .inactive,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		if numberOfEnabledHours < TracingStatusHistory.minimumActiveHours {
			Log.info("RiskProvider: Precondition not met for minimumActiveHours", log: .riskDetection)
			return Risk(
				level: .unknownInitial,
				details: details,
				riskLevelHasChanged: false // false because we don't want to trigger a notification
			)
		}

		let enoughTimeHasPassed = riskProvidingConfiguration.shouldPerformExposureDetection(
			activeTracingHours: numberOfEnabledHours,
			lastExposureDetectionDate: store.riskCalculationResult?.calculationDate
		)
		let shouldDetectExposures = (riskProvidingConfiguration.detectionMode == .manual && userInitiated) || riskProvidingConfiguration.detectionMode == .automatic

		if !enoughTimeHasPassed || !shouldDetectExposures || !shouldDetectExposureBecauseOfNewPackages,
		   let riskCalculationResult = store.riskCalculationResult {
			Log.info("RiskProvider: Not calculating new risk, using result of most recent risk calculation", log: .riskDetection)

			// Using the same riskCalculationResult twice so that risk.riskLevelHasChanged is set to false
			return Risk(activeTracing: tracingHistory.activeTracing(), riskCalculationResult: riskCalculationResult, previousRiskCalculationResult: riskCalculationResult)
		}

		return nil
	}

	private var shouldDetectExposureBecauseOfNewPackages: Bool {
		let lastKeyPackageDownloadDate = store.lastKeyPackageDownloadDate
		let lastExposureDetectionDate = store.riskCalculationResult?.calculationDate ?? .distantPast
		let didDownloadNewPackagesSinceLastDetection = lastKeyPackageDownloadDate > lastExposureDetectionDate
		let hoursSinceLastDetection = -lastExposureDetectionDate.hoursSinceNow
		let lastDetectionMoreThan24HoursAgo = hoursSinceLastDetection > 24

		return didDownloadNewPackagesSinceLastDetection || lastDetectionMoreThan24HoursAgo
	}

	private func executeExposureDetection(
		appConfiguration: SAP_Internal_ApplicationConfiguration,
		completion: @escaping (Result<[ExposureWindow], RiskProviderError>) -> Void
	) {
		self.updateActivityState(.detecting)

		// The summary is outdated: do a exposure detection
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

				/// We were able to calculate a risk so we have to reset the deadman notification
				UNUserNotificationCenter.current().resetDeadmanNotification()
				completion(.success(exposureWindows))
			case .failure(let error):
				Log.error("RiskProvider: Detect exposure failed", log: .riskDetection, error: error)

				completion(.failure(.failedRiskDetection(error)))
			}
		}

		self.exposureDetection = _exposureDetection
	}

	private func calculateRiskLevel(exposureWindows: [ExposureWindow], appConfiguration: SAP_Internal_ApplicationConfiguration?, completion: (Result<Risk, RiskProviderError>) -> Void?) {
		Log.info("RiskProvider: Calculate risk level", log: .riskDetection)

		guard let appConfiguration = appConfiguration else {
			completion(.failure(.missingAppConfig))
			return
		}

		// TODO: Use actual risk calculation parameters
		let configuration = RiskCalculationConfiguration(from: SAP_Internal_V2_RiskCalculationParameters())

		do {
			let riskCalculationResult = try riskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)

			let risk = Risk(
				activeTracing: store.tracingStatusHistory.activeTracing(),
				riskCalculationResult: riskCalculationResult,
				previousRiskCalculationResult: store.riskCalculationResult
			)

			store.riskCalculationResult = riskCalculationResult
			checkIfRiskStatusLoweredAlertShouldBeShown(risk)

			completion(.success(risk))

			/// We were able to calculate a risk so we have to reset the DeadMan Notification
			UNUserNotificationCenter.current().resetDeadmanNotification()
		} catch {
			completion(.failure(.failedRiskCalculation))
		}
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

	private func checkIfRiskStatusLoweredAlertShouldBeShown(_ risk: Risk) {
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

		store.riskCalculationResult = RiskCalculationV2Result(
			riskLevel: risk.level == .increased ? .increased : .low,
			minimumDistinctEncountersWithLowRisk: 0,
			minimumDistinctEncountersWithHighRisk: 0,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			calculationDate: Date()
		)
	}
}
#endif
