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

protocol RiskProviderStore {
	var dateLastExposureDetection: Date? { get set }
	var previousSummary: ENExposureDetectionSummaryContainer? { get set }
	var tracingStatusHistory: TracingStatusHistory { get set }
}

extension SecureStore: RiskProviderStore {}

protocol ExposureSummaryProvider: AnyObject {
	typealias Completion = (ENExposureDetectionSummary?) -> Void
	func detectExposure(completion: @escaping Completion)
}

final class RiskProvider {
	private let consumers = NSHashTable<RiskConsumer>.weakObjects()
	private let queue = DispatchQueue(label: "com.sap.RiskLevelProvider")
//	private var state: State = .waiting

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
	private let exposureManagerState: ExposureManagerState
	var configuration: RiskProvidingConfiguration {
		didSet {

		}
	}
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
	func requestRisk() {
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
		let summary = newSummary ?? store.previousSummary

		guard let _appConfiguration = appConfiguration else {
			return
		}
		
		let tracingHistory = self.store.tracingStatusHistory
		let numberOfEnabledHours = tracingHistory.countEnabledHours()
		let risk = RiskCalculation.risk(
			summary: summary,
			configuration: _appConfiguration,
			dateLastExposureDetection: self.store.dateLastExposureDetection,
			numberOfTracingActiveHours: numberOfEnabledHours,
			preconditions: self.exposureManagerState,
			currentDate: Date()
		)

		for consumer in consumers.allObjects {
			switch risk {
			case .success(let rl):
				_provideRisk(rl, to: consumer)
			case .failure:
				print("fail")
			}
		}
	}

	private func _provideRisk(_ risk: Risk, to consumer: RiskConsumer?) {
		consumer?.provideRisk(risk)
	}
}
