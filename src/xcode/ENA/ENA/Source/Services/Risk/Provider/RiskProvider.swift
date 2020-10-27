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

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (Result<ENExposureDetectionSummary, ExposureDetection.DidEndPrematurelyReason>) -> Void
	func detectExposure(
		appConfiguration: SAP_ApplicationConfiguration,
		activityStateDelegate: ActivityStateProviderDelegate?,
		completion: @escaping Completion
	) -> CancellationToken
}

/// This protocol is used to provide an up-to-date exposure detection state for the RiskProvider.
protocol ActivityStateProviderDelegate: class {
	func provideActivityState(_ state: RiskProvider.ActivityState)
}

final class RiskProvider {

	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let targetQueue: DispatchQueue
	private var consumersQueue = DispatchQueue(label: "com.sap.RiskProvider.consumer")
	private var cancellationToken: CancellationToken?
	private let riskCalculation: RiskCalculationProtocol

	private var _consumers: [RiskConsumer] = []
	private var consumers: [RiskConsumer] {
		get { consumersQueue.sync { _consumers } }
		set { consumersQueue.sync { _consumers = newValue } }
	}

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		exposureSummaryProvider: ExposureSummaryProvider,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState,
		targetQueue: DispatchQueue = .main,
		riskCalculation: RiskCalculationProtocol = RiskCalculation()
	) {
		self.configuration = configuration
		self.store = store
		self.exposureSummaryProvider = exposureSummaryProvider
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
		self.riskCalculation = riskCalculation

		self.$activityState
			.removeDuplicates()
			.debounce(for: .milliseconds(250), scheduler: RunLoop.main)
			.sink { [weak self] state in self?._provideActivityState(state) }
			.store(in: &subscriptions)
	}

	// MARK: Properties
	private var subscriptions = Set<AnyCancellable>()
	private let store: Store
	private let exposureSummaryProvider: ExposureSummaryProvider
	private let appConfigurationProvider: AppConfigurationProviding
	@Published private(set) var activityState: ActivityState = .idle
	var exposureManagerState: ExposureManagerState
	var configuration: RiskProvidingConfiguration
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
		configuration.manualExposureDetectionState(
			activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
			lastExposureDetectionDate: store.summary?.date)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk(userInitiated: Bool, ignoreCachedSummary: Bool = false, completion: Completion? = nil) {
		queue.async {
			self._requestRiskLevel(userInitiated: userInitiated, ignoreCachedSummary: ignoreCachedSummary, completion: completion)
		}
	}

	private func determineSummary(
		userInitiated: Bool,
		ignoreCachedSummary: Bool = false,
		appConfiguration: SAP_ApplicationConfiguration,
		completion: @escaping (Result<SummaryMetadata?, ExposureDetection.DidEndPrematurelyReason>) -> Void
	) {
		Log.info("RiskProvider: Determine summeries.", log: .riskDetection)
		if !ignoreCachedSummary {
			// Here we are in automatic mode and thus we have to check the validity of the current summary
			let enoughTimeHasPassed = configuration.shouldPerformExposureDetection(
				activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
				lastExposureDetectionDate: store.summary?.date
			)
			if !enoughTimeHasPassed || !self.exposureManagerState.isGood {
				completion(.success(store.summary))
				return
			}

			// Enough time has passed.
			let shouldDetectExposures = (configuration.detectionMode == .manual && userInitiated) || configuration.detectionMode == .automatic

			if shouldDetectExposures == false {
				completion(.success(store.summary))
				return
			}
		}

		// The summary is outdated: do a exposure detection
		self.cancellationToken = exposureSummaryProvider.detectExposure(appConfiguration: appConfiguration, activityStateDelegate: self) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let detectedSummary):
				self.store.summary = SummaryMetadata(detectionSummary: detectedSummary, date: Date())

				/// We were able to calculate a risk so we have to reset the deadman notification
				UNUserNotificationCenter.current().resetDeadmanNotification()
				completion(.success(self.store.summary))
			case .failure(let error):
				completion(.failure(error))
			}

			self.cancellationToken = nil
		}
	}

	/// Returns the next possible date of a exposureDetection
	/// Case1: Date is a valid date in the future
	/// Case2: Date is in the past (could be .distantPast) (usually happens when no detection has been run before (e.g. fresh install).
	/// For Case2, we need to calculate the remaining time until we reach a full 24h of tracing.
	func nextExposureDetectionDate() -> Date {
		let nextDate = configuration.nextExposureDetectionDate(
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

	private func successOnTargetQueue(risk: Risk, completion: Completion? = nil) {
		targetQueue.async {
			completion?(.success(risk))
		}

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}
	}

	private func failOnTargetQueue(error: RiskCalculationError, completion: Completion? = nil) {
		targetQueue.async {
			completion?(.failure(error))
		}

		for consumer in consumers {
			_provideRiskResult(.failure(error), to: consumer)
		}
	}

	private func _requestRiskLevel(userInitiated: Bool, ignoreCachedSummary: Bool, completion: Completion? = nil) {
		Log.info("RiskProvider: Request risk level", log: .riskDetection)

		#if DEBUG
		if isUITesting {
			_requestRiskLevel_Mock(userInitiated: userInitiated, completion: completion)
			return
		}
		#endif

		provideActivityState(.idle)
		let tracingHistory = store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.activeTracing().inHours
		let details = Risk.Details(
			daysSinceLastExposure: store.summary?.summary.daysSinceLastExposure,
			numberOfExposures: Int(store.summary?.summary.matchedKeyCount ?? 0),
			activeTracing: tracingHistory.activeTracing(),
			exposureDetectionDate: store.summary?.date
		)

		// Risk Calculation involves some potentially long running tasks, like exposure detection and
		// fetching the configuration from the backend.
		// However in some precondition cases we can return early, mainly:
		// 1. The exposureManagerState is bad (turned off, not authorized, etc.)
		// 2. Tracing has not been active for at least 24 hours
		guard exposureManagerState.isGood else {
			successOnTargetQueue(
				risk: Risk(
					level: .inactive,
					details: details,
					riskLevelHasChanged: false // false because we don't want to trigger a notification
				), completion: completion
			)
			return
		}

		guard numberOfEnabledHours >= TracingStatusHistory.minimumActiveHours else {
			successOnTargetQueue(
				risk: Risk(
					level: .unknownInitial,
					details: details,
					riskLevelHasChanged: false // false because we don't want to trigger a notification
				), completion: completion
			)
			return
		}

		let group = DispatchGroup()

		group.enter()

		appConfigurationProvider.appConfiguration { [weak self] result in

			switch result {
			case .success(let config):
				self?.determineSummary(
					userInitiated: userInitiated,
					ignoreCachedSummary: ignoreCachedSummary,
					appConfiguration: config,
					completion: { result in
						guard let self = self else { return }

						switch result {
						case .success(let summary):
							self._requestRiskLevel(
								summary: summary,
								appConfiguration: config,
								completion: completion
							)
						case .failure(let error):
							Log.info("RiskProvider: Failed determining summary.", log: .riskDetection)
							self.failOnTargetQueue(
								error: .failedRiskDetection(error),
								completion: completion
							)
						}

						group.leave()
					}
				)
			case .failure(let error):
				Log.error(error.localizedDescription, log: .api)
				self?.failOnTargetQueue(error: .missingAppConfig, completion: completion)
				group.leave()
			}
		}

		guard group.wait(timeout: .now() + .seconds(60 * 8)) == .success else {
			cancellationToken?.cancel()
			cancellationToken = nil
			Log.info("RiskProvider: Canceled risk calculation due to timeout", log: .riskDetection)
			failOnTargetQueue(error: .timeout, completion: completion)
			return
		}

		cancellationToken = nil
	}

	private func _requestRiskLevel(summary: SummaryMetadata?, appConfiguration: SAP_ApplicationConfiguration, completion: Completion? = nil) {
		Log.info("RiskProvider: Apply risk calculation", log: .riskDetection)

		let activeTracing = store.tracingStatusHistory.activeTracing()

		guard
			let risk = riskCalculation.risk(
				summary: summary?.summary,
				configuration: appConfiguration,
				dateLastExposureDetection: summary?.date,
				activeTracing: activeTracing,
				preconditions: exposureManagerState,
				previousRiskLevel: store.previousRiskLevel,
				providerConfiguration: configuration
			) else {
				Log.error("Serious error during risk calculation", log: .api)
				failOnTargetQueue(error: .failedRiskCalculation, completion: completion)
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

		successOnTargetQueue(risk: risk, completion: completion)
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
}

extension RiskProvider: ActivityStateProviderDelegate {

	/// - NOTE: The activity state is propagated to subscribers
	/// via a sink that can be found in the RiskProvider initializer.
	func provideActivityState(_ state: ActivityState) {
		activityState = state
	}

	private func _provideActivityState(_ state: ActivityState) {
		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeActivityState?(state)
			}
		}
	}
}

extension RiskProvider {
	enum ActivityState {
		case idle
		case downloading
		case detecting

		var isActive: Bool {
			self != .idle
		}
	}
}

#if DEBUG
extension RiskProvider {
	private func _requestRiskLevel_Mock(userInitiated: Bool, completion: Completion? = nil) {
		let risk = Risk.mocked

		targetQueue.async {
			completion?(.success(.mocked))
		}

		for consumer in consumers {
			_provideRiskResult(.success(risk), to: consumer)
		}

		savePreviousRiskLevel(risk)
	}
}
#endif
