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
- numberOfActiveTracingDays: Int = 0
- preconditions: ExposureManagerState
*/

protocol RiskLevelProviderStore {
	var dateLastExposureDetection: Date? { get set }
	var previousSummary: ENExposureDetectionSummaryContainer? { get set }
	var tracingStatusHistory: TracingStatusHistory { get set }
}

extension SecureStore: RiskLevelProviderStore {}

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (ENExposureDetectionSummary?) -> Void
	func detectExposure(completion: @escaping Completion)
}



final class RiskLevelProvider {
	private let consumers = NSHashTable<RiskLevelConsumer>.weakObjects()
	private let queue = DispatchQueue(label: "com.sap.RiskLevelProvider")
	private var state: State = .waiting

	// MARK: Creating a Risk Level Provider
	init(
		configuration: RiskLevelProvidingConfiguration,
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
	private let exposureManagerState: ExposureManagerState
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

private extension RiskLevelConsumer {
	func provideRiskRevel(_ riskLevel: RiskLevel) {
		targetQueue.async { [weak self] in
			self?.didCalculateRiskLevel?(riskLevel)
		}

	}
	func provideNextExposureDetectionDate(_ date: Date) {
		targetQueue.async { [weak self] in
			self?.nextExposureDetectionDateDidChange?(date)
		}
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

		let group = DispatchGroup()

		if requiresExposureDetectionRun {
			group.enter()
			exposureSummaryProvider.detectExposure {
				defer { group.leave() }
				if let detectedSummary = $0 {
					newSummary = ENExposureDetectionSummaryContainer(with: detectedSummary)
				}
			}
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
		
		let tracingHistory = self.store.tracingStatusHistory
		let numberOfEnabledDays = tracingHistory.countEnabledDays()
		let riskLevel = RiskExposureCalculation.riskLevel(
			summary: nil,
			configuration: _appConfiguration,
			dateLastExposureDetection: self.store.dateLastExposureDetection,
			numberOfTracingActiveDays: numberOfEnabledDays,
			preconditions: self.exposureManagerState,
			currentDate: Date()
		)

		for consumer in consumers.allObjects {
			switch riskLevel {
			case .success(let rl):
				_provideRiskLevel(rl, to: consumer)
			case .failure:
				print("fail")
			}
		}
	}

	private func _provideRiskLevel(_ riskLevel: RiskLevel, to consumer: RiskLevelConsumer?) {
		consumer?.provideRiskRevel(riskLevel)
	}
}
