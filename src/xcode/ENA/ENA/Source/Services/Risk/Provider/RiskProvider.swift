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

		let exposureDetectionValidityDuration = configuration.exposureDetectionValidityDuration
		// Using .distantPast here simplifies the algorithm a bit
		let lastExposureDetectionDate = store.summaryDate ?? .distantPast

		let nextExposureDetectionDate: Date = {
			let now = Date()
			// `proposedDate` can be way back in the past (because of `.distantPast` (see above)).
			// But the next exposure detection date should always be between:
			// `now` and `now + exposureDetectionValidityDuration`. That is why we ignore the past
			// and cut the proposed date off at `now`.
			let proposedDate = Calendar.current.date(
				byAdding: exposureDetectionValidityDuration,
				to: lastExposureDetectionDate,
				wrappingComponents: false
				) ?? now

			return proposedDate < now ? now : proposedDate
		}()

		consumer.nextExposureDetectionDateDidChange?(nextExposureDetectionDate)
	}

	/// Called by consumers to request the risk level. This method triggers the risk level process.
	func requestRisk() {
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
			let exposureDetectionIsValid = configuration.exposureDetectionIsValid(lastExposureDetectionDate: store.summaryDate)
			if exposureDetectionIsValid {
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

			// The summary is outdated + we are in automatic mode: do a exposure detection
			exposureSummaryProvider.detectExposure { detectedSummary in
				guard let detectedSummary = detectedSummary else { return }
				let current = ENExposureDetectionSummaryContainer(with: detectedSummary)

//				self.store.beginTransaction()
				let previous = self.store.summary
				let previousDate = self.store.summaryDate
//				self.store.commit()

//				self.store.beginTransaction()
				self.store.summary = current
				///
				self.store.summaryDate = Date()
//				self.store.commit()
				completion(
					.init(
						previous: previous,
						previousDate: previousDate,
						current: current,
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
