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

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (ENExposureDetectionSummary?) -> Void
	func detectExposure(completion: @escaping Completion)
}

final class RiskProvider {

	private let queue = DispatchQueue(label: "com.sap.RiskProvider")
	private let targetQueue: DispatchQueue
	private var consumersQueue = DispatchQueue(label: "com.sap.RiskProvider")

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
		targetQueue: DispatchQueue = .main
	) {
		self.configuration = configuration
		self.store = store
		self.exposureSummaryProvider = exposureSummaryProvider
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
		self.targetQueue = targetQueue
	}

	// MARK: Properties
	private let store: Store
	private let exposureSummaryProvider: ExposureSummaryProvider
	private let appConfigurationProvider: AppConfigurationProviding
	var exposureManagerState: ExposureManagerState
	var configuration: RiskProvidingConfiguration
	private(set) var isLoading: Bool = false
}

private extension RiskConsumer {
	func provideRisk(_ risk: Risk) {
		targetQueue.async { [weak self] in
			self?.didCalculateRisk(risk)
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
	func requestRisk(userInitiated: Bool, completion: Completion? = nil) {
		queue.async {
			self._requestRiskLevel(userInitiated: userInitiated, completion: completion)
		}
	}

	private struct Summaries {
		var previous: SummaryMetadata?
		var current: SummaryMetadata?
	}

	private func determineSummaries(
		userInitiated: Bool,
		completion: @escaping (Summaries) -> Void
	) {
		// Here we are in automatic mode and thus we have to check the validity of the current summary
		let enoughTimeHasPassed = configuration.shouldPerformExposureDetection(
			activeTracingHours: store.tracingStatusHistory.activeTracing().inHours,
			lastExposureDetectionDate: store.summary?.date
		)
		if !enoughTimeHasPassed || !self.exposureManagerState.isGood {
			completion(
				.init(
					previous: nil,
					current: store.summary
				)
			)
			return
		}

		// Enough time has passed.
		let shouldDetectExposures = (configuration.detectionMode == .manual && userInitiated) || configuration.detectionMode == .automatic

		if shouldDetectExposures == false {
			completion(
				.init(
					previous: nil,
					current: store.summary
				)
			)
			return
		}

		// The summary is outdated + we are in automatic mode: do a exposure detection
		let previousSummary = store.summary

		exposureSummaryProvider.detectExposure { detectedSummary in
			if let detectedSummary = detectedSummary {
				self.store.summary = .init(detectionSummary: detectedSummary, date: Date())
			}
			completion(
				.init(
					previous: previousSummary,
					current: self.store.summary
				)
			)
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

	#if UITESTING
	private func _requestRiskLevel(userInitiated: Bool, completion: Completion? = nil) {
		let risk = Risk.mocked

		targetQueue.async {
			completion?(.mocked)
		}

		for consumer in consumers {
			_provideRisk(risk, to: consumer)
		}

		saveRiskIfNeeded(risk)
	}
	#else

	private func completeOnTargetQueue(risk: Risk?, completion: Completion? = nil) {
		targetQueue.async {
			completion?(risk)
		}
		// We only wish to notify consumers if an actual risk level has been calculated.
		// We do not notify if an error occurred.
		if let risk = risk {
			for consumer in consumers {
				_provideRisk(risk, to: consumer)
			}
		}
	}

	private func _requestRiskLevel(userInitiated: Bool, completion: Completion? = nil) {
		var summaries: Summaries?
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
			completeOnTargetQueue(
				risk: Risk(
					level: .inactive,
					details: details,
					riskLevelHasChanged: false // false because we don't want to trigger a notification
				), completion: completion
			)
			return
		}

		guard numberOfEnabledHours >= TracingStatusHistory.minimumActiveHours else {
			completeOnTargetQueue(
				risk: Risk(
					level: .unknownInitial,
					details: details,
					riskLevelHasChanged: false // false because we don't want to trigger a notification
				), completion: completion
			)
			return
		}

		provideLoadingStatus(isLoading: true)
		let group = DispatchGroup()

		group.enter()
		determineSummaries(userInitiated: userInitiated) {
			summaries = $0
			group.leave()
		}

		var appConfiguration: SAP_ApplicationConfiguration?
		group.enter()
		appConfigurationProvider.appConfiguration { configuration in
			appConfiguration = configuration
			group.leave()
		}

		guard group.wait(timeout: .now() + .seconds(60)) == .success else {
			provideLoadingStatus(isLoading: false)
			completeOnTargetQueue(risk: nil, completion: completion)
			return
		}

		_requestRiskLevel(summaries: summaries, appConfiguration: appConfiguration, completion: completion)
	}

	private func _requestRiskLevel(summaries: Summaries?, appConfiguration: SAP_ApplicationConfiguration?, completion: Completion? = nil) {
		guard let _appConfiguration = appConfiguration else {
			provideLoadingStatus(isLoading: false)
			completeOnTargetQueue(risk: nil, completion: completion)
			return
		}

		let activeTracing = store.tracingStatusHistory.activeTracing()

		guard
			let risk = RiskCalculation.risk(
				summary: summaries?.current?.summary,
				configuration: _appConfiguration,
				dateLastExposureDetection: summaries?.current?.date,
				activeTracing: activeTracing,
				preconditions: exposureManagerState,
				currentDate: Date(),
				previousRiskLevel: store.previousRiskLevel,
				providerConfiguration: configuration
			) else {
				logError(message: "Serious error during risk calculation")
				provideLoadingStatus(isLoading: false)
				completeOnTargetQueue(risk: nil, completion: completion)
				return
		}

		provideLoadingStatus(isLoading: false)
		completeOnTargetQueue(risk: risk, completion: completion)
		saveRiskIfNeeded(risk)
	}
	#endif

	private func _provideRisk(_ risk: Risk, to consumer: RiskConsumer?) {
		#if UITESTING
		consumer?.provideRisk(.mocked)
		#else
		consumer?.provideRisk(risk)
		#endif
	}

	private func provideLoadingStatus(isLoading: Bool) {
		self.isLoading = isLoading
		_provideLoadingStatus(isLoading)
	}

	private func _provideLoadingStatus(_ isLoading: Bool) {
		targetQueue.async { [weak self] in
			self?.consumers.forEach {
				$0.didChangeLoadingStatus?(isLoading)
			}
		}
	}

	private func saveRiskIfNeeded(_ risk: Risk) {
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
