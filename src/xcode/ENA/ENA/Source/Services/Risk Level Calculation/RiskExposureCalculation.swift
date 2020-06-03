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









/// When the user (either as a scheduled task or on-demand) wants to re-calculate their risk level, this class is used.
///
/// High level steps:
///		1. Check if notification exposure is turned on, if not risk is at `.inactive`
///		2. Check for downloaded keys. If there are none, risk is at `unknownInitial`
///		3. Check the tracing duration. It must have been active for at least `RiskExposureCalculationSpec.minTracingTime`. If not risk level is `.unknownInitial`
///		4. Check if the last exposure detection run is outdated. If it is stale beyond 24h then risk level is `.unknownOutdated`
///		5. Trigger a `ExposureDetection`
///		6. Wait for failure or success
///
final class RiskExposureCalculation {
	private let queue = DispatchQueue(label: "com.sap.RiskExposureCalculation")
	typealias CalculationCompletion = (Result<RiskLevel, ExposureDetection.DidEndPrematurelyReason>) -> Void
	// MARK: - Properties

	// Serial queue to handle multiple calculation requests one after another
	// TODO: Put on background queue? We will need to block!

	private let exposureState: ExposureManagerState
	private let downloadedPackagesStore: DownloadedPackagesStore
	private let client: Client
	private let store: Store
	private var completion: CalculationCompletion?		// Only set once `start(_:)` has been called
	private var exposureSummaryNotification: NSObjectProtocol?
	private var exposureSummaryDidFailNotification: NSObjectProtocol?

	// MARK: - Creating a RiskExposureCalculationTransaction

	init(
		exposureState: ExposureManagerState,
		client: Client,
		store: Store,
		downloadedPackagesStore: DownloadedPackagesStore
	) {
		self.exposureState = exposureState
		self.store = store
		self.downloadedPackagesStore = downloadedPackagesStore
		self.client = client
	}

	func start(completion: CalculationCompletion?) {
		var calculatedRiskLevel = RiskLevel.low
		// Step 1 - Checking for Exposure Notification permissions
		if let levelChange = self.checkForPermissionsGranted(), calculatedRiskLevel < levelChange {
			calculatedRiskLevel = levelChange
		}

		// Step 2 - Check for downloaded keys
		if let levelChange = self.checkForDownloadedKeys(), calculatedRiskLevel < levelChange {
			calculatedRiskLevel = levelChange
		}

		// Step 3 - Check the tracing duration. Tracing must have been active for at least 24h
		if let levelChange = self.checkTraceActiveDuration(), calculatedRiskLevel < levelChange {
			calculatedRiskLevel = levelChange
		}

		// Step 4 - Check if the risk level is outdated
		if let levelChange = self.checkForOutdatedExposureCalculation(), calculatedRiskLevel < levelChange {
			calculatedRiskLevel = levelChange
		}

		guard
			calculatedRiskLevel != .inactive,
			calculatedRiskLevel != .unknownInitial,
			calculatedRiskLevel != .unknownOutdated
			else {
				completion?(.success(calculatedRiskLevel))
				return
		}

		guard let summary = store.previousSummary else {
			completion?(.failure(.noSummary(nil)))
			return
		}
		let maxRiskLevel = RiskLevel(riskScore: summary.maximumRiskScore)
		completion?(.success(maxRiskLevel))

	}

	// MARK: - Internal Workers

	/// Step 1 - Check for permissions
	private func checkForPermissionsGranted() -> RiskLevel? {
		return exposureState.isGood ? nil : .inactive
	}

	/// Step 2 - Check for downloaded keys
	private func checkForDownloadedKeys() -> RiskLevel? {
		// TODO: Verify this is the process
		return nil
//		return self.keyPackagesStore.allDays().isEmpty ? .unknownInitial : nil
	}

	/// Step 3 - Check tracing duration. If intital tracing was activated less than 24h before, we are in state `RiskLevel.unknownInitial`
	private func checkTraceActiveDuration() -> RiskLevel? {
		// TODO
		nil
	}

	/// Step 4 - Check if the exposure dection last run is outdated, if so risk  level is `.unknownOutdated`
	private func checkForOutdatedExposureCalculation() -> RiskLevel? {
		guard let dateLastExposureDetection = store.dateLastExposureDetection else {
			return .unknownInitial
		}

		if Date().timeIntervalSince(dateLastExposureDetection) < RiskExposureCalculationSpec.lastExposureDetectionStaleThreshold {
			return nil
		} else {
			return .unknownOutdated
		}
	}
}

// TODO: Put these somewhere better (+ convenience extension on TimeInterval?)
enum RiskExposureCalculationSpec {
	/// The minimum duration (in seconds) tracing should be active for risk calculation to work
	/// - attention: Represented in seconds, currently 24hours
	static let minTracingTime: TimeInterval = 24 * 60 * 60
	/// A `RiskLevel` is considered stale if no diagnosis keys have been fetched in this time interval
	/// - attention: Represented in seconds, currently 24hours
	static let lastExposureDetectionStaleThreshold: TimeInterval = 24 * 60 * 60
}

extension Date {
	var isWithinExposureDetectionValidInterval: Bool {
		Calendar.current.dateComponents(
			[.day],
			from: Date(),
			to: self
		).day ?? .max < 1
	}
}
