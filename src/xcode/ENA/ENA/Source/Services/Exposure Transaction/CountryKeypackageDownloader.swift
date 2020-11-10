//
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
//

import ExposureNotification

protocol CountryKeypackageDownloading {
	typealias Completion = (Result<Void, ExposureDetection.DidEndPrematurelyReason>) -> Void

	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion)
}

class CountryKeypackageDownloader: CountryKeypackageDownloading {

	private weak var delegate: ExposureDetectionDelegate?

	init(delegate: ExposureDetectionDelegate?) {
		self.delegate = delegate
	}

	func downloadKeypackages(for country: Country.ID, completion: @escaping Completion) {

		Log.info("CountryKeypackageDownloader: Start determine available data.", log: .riskDetection)

		delegate?.exposureDetection(country: country, determineAvailableData: { [weak self] daysAndHours, country in
			guard let self = self else { return }
			Log.info("CountryKeypackageDownloader: Completed determine available data.", log: .riskDetection)

			self.downloadDeltaUsingAvailableRemoteData(daysAndHours, country: country, completion: completion)
		})
	}

	private func downloadDeltaUsingAvailableRemoteData(_ daysAndHours: DaysAndHours?, country: Country.ID, completion: @escaping Completion) {

		Log.info("CountryKeypackageDownloader: Determine delta data.", log: .riskDetection)

		guard let daysAndHours = daysAndHours else {
			completion(.failure(.noDaysAndHours))
			return
		}

		guard let deltaDaysAndHours = delegate?.exposureDetection(country: country, downloadDeltaFor: daysAndHours) else {
			completion(.failure(.noDaysAndHours))
			return
		}

		Log.info("CountryKeypackageDownloader: Completed determine delta data.", log: .riskDetection)

		Log.info("CountryKeypackageDownloader: Start downloading delta data.", log: .riskDetection)
		delegate?.exposureDetection(country: country, downloadAndStore: deltaDaysAndHours) { error in
			if let error = error {
				Log.error("CountryKeypackageDownloader: Error while downloading delta data.", log: .riskDetection, error: error)
				completion(.failure(error))
			} else {
				Log.info("CountryKeypackageDownloader: Completed downloading delta data.", log: .riskDetection)
				completion(.success(()))
			}
		}
	}

}
