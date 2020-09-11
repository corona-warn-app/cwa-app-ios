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
	private var progress: Progress?

	#if INTEROP

	private let store: Store

	// MARK: Creating a Transaction
	init(delegate: ExposureDetectionDelegate, store: Store) {
		self.delegate = delegate
		self.store = store
	}

	#else

	// MARK: Creating a Transaction
	init(delegate: ExposureDetectionDelegate) {
		self.delegate = delegate
	}

	#endif

	func cancel() {
		progress?.cancel()
	}

	#if INTEROP

	var keypackageDownloads = [CountryKeypackageDownload]()

	private func downloadKeyPackages(for countries: [Country.ID], completion: @escaping (DidEndPrematurelyReason?) -> Void) {

		let dispatchGroup = DispatchGroup()
		var errors = [ExposureDetection.DidEndPrematurelyReason]()

		for country in countries {
			dispatchGroup.enter()

			let keypackageDownload = CountryKeypackageDownload(country: country, delegate: delegate)
			keypackageDownloads.append(keypackageDownload)
			keypackageDownload.execute { result in

				switch result {
				case .failure(let didEndPrematurelyReason):
					errors.append(didEndPrematurelyReason)
				case .success:
					break
				}

				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			if let error = errors.first {
				completion(error)
			} else {
				completion(nil)
			}
		}
	}

	private func writeKeyPackagesToFileSystem(for countries: [Country.ID]) -> WrittenPackages? {
		var urls = [URL]()
		for country in countries {
			guard let writtenPackages = self.delegate?.exposureDetectionWriteDownloadedPackages(country: country) else {
				return nil
			}
			urls.append(contentsOf: writtenPackages.urls)
		}

		return WrittenPackages(urls: urls)
	}

	private func detectSummary(writtenPackages: WrittenPackages) {
		delegate?.exposureDetection(country: "DE", downloadConfiguration: { [weak self] configuration, _ in
			guard let self = self else { return }

			guard let configuration = configuration else {
				self.endPrematurely(reason: .noExposureConfiguration)
				return
			}

			self.progress = self.delegate?.exposureDetection(
				self,
				detectSummaryWithConfiguration: configuration,
				writtenPackages: writtenPackages
			) { [weak self] result in
				writtenPackages.cleanUp()
				self?.useSummaryResult(result)
			}

		})
	}

	#else

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
		self.progress = delegate?.exposureDetection(
			self,
			detectSummaryWithConfiguration: configuration,
			writtenPackages: writtenPackages
		) { [weak self] result in
			writtenPackages.cleanUp()
			self?.useSummaryResult(result)
		}
	}
	#endif

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

		#if INTEROP

		delegate?.exposureDetection(supportedCountries: { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let countries):
				let countryIDs = countries.map { $0.id }

				self.downloadKeyPackages(for: countryIDs) { [weak self] didEndPrematurelyReason in
					guard let self = self else { return }

					if let didEndPrematurelyReason = didEndPrematurelyReason {
						self.endPrematurely(reason: didEndPrematurelyReason)
					} else {
						guard let writtenPackages = self.writeKeyPackagesToFileSystem(for: countryIDs) else {
							self.endPrematurely(reason: .unableToWriteDiagnosisKeys)
							return
						}
						self.detectSummary(writtenPackages: writtenPackages)
					}
				}
			case.failure:
				self.endPrematurely(reason: .noSupportedCountries)
			}
		})

		#else

		delegate?.exposureDetection(self, determineAvailableData: downloadDeltaUsingAvailableRemoteData)

		#endif
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
