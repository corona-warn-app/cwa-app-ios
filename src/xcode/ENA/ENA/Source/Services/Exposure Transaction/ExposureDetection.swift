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

/// Every time the user wants to know the own risk the app creates an `ExposureDetection`.
final class ExposureDetection {
	// MARK: Properties
	private weak var delegate: ExposureDetectionDelegate?
	private var completion: Completion?

	// MARK: Creating a Transaction
	init(delegate: ExposureDetectionDelegate) {
		self.delegate = delegate
	}

	// MARK: Starting the Transaction
	// Called right after the transaction knows which data is available remotly.
	private func downloadDeltaUsingAvailableRemoteData(_ remote: DaysAndHours?) {
		guard let remote = remote else {
			endPrematurely(reason: .noDaysAndHours)
			return
		}
		guard let delta = delegate?.exposureDetection(self, downloadDeltaFor: remote) else {
			endPrematurely(reason: .noDaysAndHours)
			return
		}
		delegate?.exposureDetection(self, downloadAndStore: delta) { [weak self] error in
			guard let self = self else { return }
			if error != nil {
				self.endPrematurely(reason: .noDaysAndHours)
				return
			}
			self.delegate?.exposureDetection(self, downloadConfiguration: self.useConfiguration)
		}
	}

	private func useConfiguration(_ configuration: ENExposureConfiguration?) {
		guard let configuration = configuration else {
			endPrematurely(reason: .noExposureConfiguration)
			return
		}
		guard let writtenPackages = delegate?.exposureDetectionWriteDownloadedPackages(self) else {
			endPrematurely(reason: .unableToWriteDiagnosisKeys)
			return
		}
		delegate?.exposureDetection(
			self,
			detectSummaryWithConfiguration: configuration,
			writtenPackages: writtenPackages
		) { [weak self] result in
			writtenPackages.cleanUp()
			self?.useSummaryResult(result)
		}
	}

	private func useSummaryResult(_ result: Result<ENExposureDetectionSummary, Error>) {
		switch result {
		case .success(let summary):
			didDetectSummary(summary)
		case .failure(let error):
			endPrematurely(reason: .noSummary(error))
		}
	}

	typealias Completion = (Result<ENExposureDetectionSummary, DidEndPrematurelyReason>) -> Void
	func start(completion: @escaping Completion) {
		self.completion = completion
		delegate?.exposureDetection(self, determineAvailableData: downloadDeltaUsingAvailableRemoteData)
	}

	// MARK: Working with the Completion Handler

	// Ends the transaction prematurely with a given reason.
	private func endPrematurely(reason: DidEndPrematurelyReason) {
		precondition(
			completion != nil,
			"Tried to end a detection prematurely is only possible if a detection is currently running."
		)
		DispatchQueue.main.async {
			self.completion?(.failure(reason))
			self.completion = nil
		}
	}

	// Informs the delegate about a summary.
	private func didDetectSummary(_ summary: ENExposureDetectionSummary) {
		precondition(
			completion != nil,
			"Tried report a summary but no completion handler is set."
		)
		DispatchQueue.main.async {
			self.completion?(.success(summary))
			self.completion = nil
		}

	}
}
