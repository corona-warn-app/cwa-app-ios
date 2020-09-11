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

#if INTEROP

class CountryKeypackageDownload {

	typealias Completion = (Result<Void, ExposureDetection.DidEndPrematurelyReason>) -> Void

	private let country: String
	private weak var delegate: ExposureDetectionDelegate?
	private var completion: Completion?


	init(country: String, delegate: ExposureDetectionDelegate?) {
		self.country = country
		self.delegate = delegate
	}

	func execute(completion: @escaping Completion) {
		self.completion = completion

		delegate?.exposureDetection(country: country, determineAvailableData: downloadDeltaUsingAvailableRemoteData)
	}

	private func downloadDeltaUsingAvailableRemoteData(_ daysAndHours: DaysAndHours?, country: String) {
		guard let daysAndHours = daysAndHours else {
			completion?(.failure(.noDaysAndHours))
			return
		}

		guard let deltaDaysAndHours = delegate?.exposureDetection(country: country, downloadDeltaFor: daysAndHours) else {
			completion?(.failure(.noDaysAndHours))
			return
		}

		delegate?.exposureDetection(country: country, downloadAndStore: deltaDaysAndHours) { [weak self] error in
			guard let self = self else { return }
			if error != nil {
				self.completion?(.failure(.noDaysAndHours))
				return
			}

			self.completion?(.success(()))
		}
	}

}
#endif
