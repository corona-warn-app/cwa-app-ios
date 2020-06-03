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


// Notes:
// The calculation will receive the following inputs:

/**
- summary: ENExposureDetectionSummaryContainer?
- exposureConfiguration: ENExposureConfiguration
- exposureDetectionValidityDuration: DateComponents
- dateLastExposureDetection: Date?
*/


protocol RiskLevelProviderStore: AnyObject {
	var dateLastExposureDetection: Date? { get set }
	var previousSummary: ENExposureDetectionSummaryContainer? { get set }
}

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (ENExposureDetectionSummary?) -> Void
	func detectExposure(completion: Completion)
}

final class RiskLevelProvider {
	private let consumers = NSHashTable<RiskLevelConsumer>.weakObjects()
	private let queue = DispatchQueue(label: "com.sap.RiskLevelProvider")
	private var state: State = .waiting

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskLevelProvidingConfiguration,
		store: RiskLevelProviderStore,
		exposureSummaryProvider: ExposureSummaryProvider
	) {
		self.configuration = configuration
		self.store = store
		self.exposureSummaryProvider = exposureSummaryProvider
	}

	// MARK: Properties
	private let store: RiskLevelProviderStore
	private let exposureSummaryProvider: ExposureSummaryProvider
	var configuration: RiskLevelProvidingConfiguration {
		didSet {

		}
	}
}

private extension RiskLevelProvider {
	enum State {
		case waiting
		case isRequestingRiskLevel
		case isDetectingExposures
	}
}


extension RiskLevelProvider: RiskLevelProviding {
	func observeRiskLevel(_ consumer: RiskLevelConsumer) {
		queue.async {
			self._observeRiskLevel(consumer)
		}
	}

	private func _observeRiskLevel(_ consumer: RiskLevelConsumer) {
		consumers.add(consumer)

		let exposureDetectionValidityDuration = configuration.exposureDetectionValidityDuration
		// Using .distantPast here simplifies the algorithm a bit
		let lastExposureDetectionDate = store.dateLastExposureDetection ?? .distantPast

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
	func requestRiskLevel() {
		queue.async(execute: _requestRiskLevel)
	}

	private func _requestRiskLevel() {
		let exposureDetectionValidUntil: Date = {
			let lastRunDate = self.store.dateLastExposureDetection ?? .distantPast
			return Calendar.current.date(
				byAdding: self.configuration.exposureDetectionValidityDuration,
				to: lastRunDate,
				wrappingComponents: false
				) ?? .distantPast
		}()

		let requiresExposureDetectionRun = Date() > exposureDetectionValidUntil

		var summary = store.previousSummary
		var newSummary: ENExposureDetectionSummaryContainer?



		//

//		client.exposureConficutatio
//		let riskLevelResult = riskLevelCalculator.riskLevel(summary, dateWhenSummaryWasDetermined, config, exposureNotificationConfiguration)
//		switch riskLevelResult {
//		case .requiresExposureDetectionRun:
//			// dispatch riskLevelResult to all consumers/ovservers
//			exposureSummaryProvider.detectExposure {
//
//			}
//		}
		if requiresExposureDetectionRun {

			let waitForSummary = DispatchSemaphore(value: 0)
			exposureSummaryProvider.detectExposure {
				if let detectedSummary = $0 {
					newSummary = ENExposureDetectionSummaryContainer(with: detectedSummary)
				}
			}
			waitForSummary.wait()
		}



		for consumer in consumers.allObjects {
			provideRiskLevel(to: consumer)
		}
	}

	private func provideRiskLevel(to: RiskLevelConsumer?) {

	}
}
