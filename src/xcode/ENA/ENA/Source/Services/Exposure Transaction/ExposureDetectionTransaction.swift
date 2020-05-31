// Corona-Warn-App
//
// SAP SE and all other contributors
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

import ExposureNotification
import Foundation

/// Every time the user wants to know the own risk the app creates an `ExposureDetectionTransaction`.
///
/// The main objective of an `ExposureDetectionTransaction` is to ensure that the
/// exposure detection/risk assesment is done as accurately as possible. An `ExposureDetectionTransaction`
/// requires a delegate to work. The delegate has several high-level tasks:
///
/// - **Provide Information:** Some methods simply provide information/objects that are required by the transaction to do the actual work.
/// - **Consume Results:** At some point the transaction generates results. The delegate is informed about them so that it can consume them.
/// - **React to Errors:** A transaction has several preconditions. If not all of them are met the transaction ends prematurely. In that case the delegate is notified along with a reason that specify details about why the transaction did end prematurely.
///
/// Under the hood the transaction execute the following steps:
///
/// ----
///
/// 1. Determine diagnosis keys that have to be downloaded.
/// 2. Download the missing keys (hours + days).
/// 3. Validate the downloaded data: Check the signatures, decode payloads, …
/// 4. Store everything that is valid and evict invalid/stale data from the local cache.
/// 5. Prepare the actual exposure detection:
///     - Transform keys into a format that can be understood by Apple.
///     - Write transformed data to disk.
///     - Get an `ExposureManager`.
/// 6. Ask for user consent if required.
/// 7. Provide everything to the Exposure Notification framework.
/// 8. Wipe everything and inform the delegate.
final class ExposureDetection {
	// MARK: Properties
	private weak var delegate: ExposureDetectionTransactionDelegate?
	let steps: TransactionSteps

	// MARK: Creating a Transaction
	init(
		delegate: ExposureDetectionTransactionDelegate,
		steps: TransactionSteps
	) {
		self.delegate = delegate
		self.steps = steps
	}

	// MARK: Starting the Transaction
	// Called right after the transaction knows which data is available remotly.
	private func downloadDeltaUsingAvailableRemoteData(_ remote: DaysAndHours?) {
		guard let remote = remote else {
			endPrematurely(reason: .noDaysAndHours)
			return
		}
		let delta = steps.determineDownloadDelta(remote: remote)
		steps.downloadAndStoreDelta(delta: delta) { [weak self] error in
			if error != nil {
				self?.endPrematurely(reason: .noDaysAndHours)
				return
			}
			self?.downloadConfiguration()
		}
	}

	private func downloadConfiguration() {
		steps.downloadConfiguration(completion: useConfiguration)
	}

	private func useConfiguration(_ configuration: ENExposureConfiguration?) {
		guard let configuration = configuration else {
			endPrematurely(reason: .noExposureConfiguration)
			return
		}
		guard let writtenPackages = steps.writeDownloadedPackages() else {
			endPrematurely(reason: .unableToDiagnosisKeys)
			return
		}
		steps.detectExposureSummary(
			configuration: configuration,
			writtenPackages: writtenPackages
		) { [weak self] result in
			writtenPackages.cleanUp()
			self?.useSummaryResult(result)
		}
	}
	private func useSummaryResult(
		_ result: Result<ENExposureDetectionSummary, Error>
	) {
		switch result {
		case .success(let summary):
			didDetectSummary(summary)
		case .failure(let error):
			endPrematurely(reason: .noSummary(error))
		}
	}

	func start() {
		steps.determineAvailableData(completion: downloadDeltaUsingAvailableRemoteData)
	}

	// MARK: Working with the Delegate

	// Ends the transaction prematurely with a given reason.
	private func endPrematurely(reason: DidEndPrematurelyReason) {
		delegate?.exposureDetectionTransaction(self, didEndPrematurely: reason)
	}

	// Informs the delegate about a summary.
	private func didDetectSummary(_ summary: ENExposureDetectionSummary) {
		delegate?.exposureDetectionTransaction(self, didDetectSummary: summary)
	}
}

extension SAP_TemporaryExposureKey {
	func toAppleKey() -> Apple_TemporaryExposureKey {
		Apple_TemporaryExposureKey.with {
			$0.keyData = self.keyData
			$0.rollingStartIntervalNumber = self.rollingStartIntervalNumber
			$0.rollingPeriod = self.rollingPeriod
			$0.transmissionRiskLevel = self.transmissionRiskLevel
		}
	}
}

private extension ENExposureConfiguration {
	var needsTemporaryFixUntilAppleFixedZeroWeightIssue: Bool {
		attenuationWeight.isNearZero ||
			durationWeight.isNearZero ||
			transmissionRiskWeight.isNearZero ||
			daysSinceLastExposureWeight.isNearZero
	}

	func fixed() -> ENExposureConfiguration {
		.mock()
	}
}

private extension Double {
	var isNearZero: Bool { magnitude < 0.1 }
}
