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
	private let consumers = NSHashTable<RiskConsumer>.weakObjects()
	private let queue = DispatchQueue(label: "com.sap.RiskLevelProvider")
	private let targetQueue: DispatchQueue

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
		queue.async { [weak self] in
			self?.consumers.add(consumer)
		}
	}

	var manualExposureDetectionState: ManualExposureDetectionState? {
		configuration.manualExposureDetectionState(lastExposureDetectionDate: store.summary?.date)
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
			lastExposureDetectionDate: store.summary?.date
		)
		if enoughTimeHasPassed == false || self.exposureManagerState.isGood == false {
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

	#if UITESTING
	private func _requestRiskLevel(userInitiated: Bool, completion: Completion? = nil) {
		let risk = Risk.mocked

		targetQueue.async {
			completion?(.mocked)
		}

		for consumer in consumers.allObjects {
			_provideRisk(risk, to: consumer)
		}

		saveRiskIfNeeded(risk)
	}
	#else
	private func _requestRiskLevel(userInitiated: Bool, completion: Completion? = nil) {
		let group = DispatchGroup()

		var summaries: Summaries?

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

		func completeOnTargetQueue(risk: Risk?) {
			targetQueue.async {
				completion?(risk)
			}
		}

		guard group.wait(timeout: .now() + .seconds(60)) == .success else {
			completeOnTargetQueue(risk: nil)
			return
		}

		guard let _appConfiguration = appConfiguration else {
			completeOnTargetQueue(risk: nil)
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
				completeOnTargetQueue(risk: nil)
				return
		}

		for consumer in consumers.allObjects {
			_provideRisk(risk, to: consumer)
		}

		completeOnTargetQueue(risk: risk)
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
