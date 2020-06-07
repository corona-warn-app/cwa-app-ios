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

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskProvidingConfiguration,
		store: Store,
		exposureSummaryProvider: ExposureSummaryProvider,
		appConfigurationProvider: AppConfigurationProviding,
		exposureManagerState: ExposureManagerState
	) {
		self.configuration = configuration
		self.store = store
		self.exposureSummaryProvider = exposureSummaryProvider
		self.appConfigurationProvider = appConfigurationProvider
		self.exposureManagerState = exposureManagerState
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
			self?.didCalculateRisk?(risk)
		}
	}
	
	func provideNextExposureDetectionDate(_ date: Date) {
		targetQueue.async { [weak self] in
			self?.nextExposureDetectionDateDidChange?(date)
		}
	}
}


extension RiskProvider {
	enum RequestType {
		case userInitiated
		case userInterface
		case background
	}
}

extension RiskProvider: RiskProviding {
	func observeRisk(_ consumer: RiskConsumer) {
		queue.async {
			self._observeRisk(consumer)
		}
	}

	func nextExposureDetectionDate() -> Date {
		configuration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.summary?.date
		)
	}

	private func _observeRisk(_ consumer: RiskConsumer) {
		consumers.add(consumer)
		consumer.nextExposureDetectionDateDidChange?(self.nextExposureDetectionDate())
		consumer.manualExposureDetectionStateDidChange?(manualExposureDetectionState)
	}

	var manualExposureDetectionState: ManualExposureDetectionState {
		let shouldPerformDetection = configuration.shouldPerformExposureDetection(
			lastExposureDetectionDate: store.summary?.date
			) && configuration.detectionMode == .manual
		return shouldPerformDetection ? .possible : .waiting
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk(userInitiated: Bool) {
		print("🧬 Requesting risk – requested by \(userInitiated ? "👩‍🔧" : "🖥")")
		print("🧬     - manualExposureDetectionState: \(manualExposureDetectionState)")


		queue.async {
			self._requestRiskLevel(userInitiated: userInitiated)
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

		print("🧬 determineSummaries:")
		print("🧬    - enoughTimeHasPassed: \(enoughTimeHasPassed)")
		print("🧬    - store.summary.date: \(String(describing: store.summary?.date))")
		print("🧬    - self.exposureManagerState: \(exposureManagerState)")

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

		print("🧬🧬🧬🧬 detecting exposured…")
		exposureSummaryProvider.detectExposure { detectedSummary in
			print("🧬🧬🧬🧬🧬 detectedSummary: \(String(describing: detectedSummary))")

			if let detectedSummary = detectedSummary {
				self.store.summary = .init(detectionSummary: detectedSummary, date: Date())
			} else {
				self.store.summary = nil
			}
			completion(
				.init(
					previous: previousSummary,
					current: self.store.summary
				)
			)
		}
	}

	private func _requestRiskLevel(userInitiated: Bool) {
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

		guard group.wait(timeout: .now() + .seconds(60)) == .success else {
			return
		}

		guard let _appConfiguration = appConfiguration else {
			return
		}
		
		let tracingHistory = store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.countEnabledHours()

		guard
			let risk = RiskCalculation.risk(
				summary: summaries?.current?.summary,
				configuration: _appConfiguration,
				dateLastExposureDetection: summaries?.current?.date,
				numberOfTracingActiveHours: numberOfEnabledHours,
				preconditions: exposureManagerState,
				currentDate: Date(),
				previousSummary: summaries?.previous?.summary
			) else {
				print("send email to christopher")
				return
		}

		for consumer in consumers.allObjects {
			_provideRisk(risk, to: consumer)
		}
	}

	private func _provideRisk(_ risk: Risk, to consumer: RiskConsumer?) {
		consumer?.provideRisk(risk)
	}
}
