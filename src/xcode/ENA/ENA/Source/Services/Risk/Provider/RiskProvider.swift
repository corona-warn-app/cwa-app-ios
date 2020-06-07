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

	private func _observeRisk(_ consumer: RiskConsumer) {
		consumers.add(consumer)
		let nextExposureDetectionDate = configuration.nextExposureDetectionDate(
			lastExposureDetectionDate: store.summaryDate
		)
		consumer.nextExposureDetectionDateDidChange?(nextExposureDetectionDate)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk() {
		print("🧏‍♂️ Requesting risk…")
		print("🧏‍♂️   - last detection: \(String(describing: store.summaryDate))")

		queue.async(execute: _requestRiskLevel)
	}

	private struct Summaries {
		var previous: ENExposureDetectionSummaryContainer?
		var previousDate: Date?

		var current: ENExposureDetectionSummaryContainer?
		var currentDate: Date?
	}

	private func _requestRiskLevel() {
		func determineSummaries(completion: @escaping (Summaries) -> Void) {
			if configuration.detectionMode == .manual {
				completion(
					.init(
						previous: nil,
						current: store.summary,
						currentDate:
						store.summaryDate
					)
				)
				return
			}
			// Here we are in automatic mode and thus we have to check the validity of the current summary
			let shouldPerformDetection = configuration.shouldPerformExposureDetection(lastExposureDetectionDate: store.summaryDate)
			if shouldPerformDetection == false {
				completion(
					.init(
						previous: nil,
						current: store.summary,
						currentDate: store.summaryDate
					)
				)
				return
			}

			// The summary is outdated + we are in automatic mode: do a exposure detection
			print("🧏‍♂️ Detecting exposures…")

			let previous = store.summary
			let previousDate = store.summaryDate

			exposureSummaryProvider.detectExposure { detectedSummary in
				print("🧏‍♂️ Got new summary detectedSummary…: \(detectedSummary)")
				self.store.summary = ENExposureDetectionSummaryContainer(with: detectedSummary)
				self.store.summaryDate = Date()

				completion(
					.init(
						previous: previous,
						previousDate: previousDate,
						current: self.store.summary,
						currentDate: self.store.summaryDate
					)
				)
			}
		}

		let group = DispatchGroup()

		var summaries: Summaries?

		group.enter()
		determineSummaries {
			defer { group.leave() }
			summaries = $0
		}

		var appConfiguration: SAP_ApplicationConfiguration?
		group.enter()
		appConfigurationProvider.appConfiguration { configuration in
			defer { group.leave() }
			appConfiguration = configuration
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
				summary: summaries?.current,
				configuration: _appConfiguration,
				dateLastExposureDetection: summaries?.currentDate,
				numberOfTracingActiveHours: numberOfEnabledHours,
				preconditions: exposureManagerState,
				currentDate: Date(),
				previousSummary: store.summary
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
