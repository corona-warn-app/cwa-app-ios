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
import ZIPFoundation

final class HTTPClientWifiOnly: ClientWifiOnly {

	// MARK: - Init

	init(
		configuration: HTTPClient.Configuration,
		session: URLSession = URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly())
	) {
		self.configuration = configuration
		self.session = session
	}

	// MARK: - Overrides

	// MARK: - Protocol ClientWifiOnly

	func fetchHour(
		_ hour: Int,
		day: String,
		country: String,
		completion completeWith: @escaping HourCompletionHandler
	) {
		let url = configuration.diagnosisKeysURL(day: day, hour: hour, forCountry: country)
		let config = URLSessionConfiguration.coronaWarnSessionConfigurationWifiOnly()
		session.configuration.allowsConstrainedNetworkAccess = config.allowsConstrainedNetworkAccess
		session.configuration.allowsExpensiveNetworkAccess = config.allowsExpensiveNetworkAccess
		var responseError: Client.Failure?
		defer {
			// no guard in defer!
			if let error = responseError {
				let retryCount = retries[url] ?? 0
				if retryCount > 2 {
					completeWith(.failure(error))
				} else {
					retries[url] = retryCount.advanced(by: 1)
					Log.debug("\(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
					fetchHour(hour, day: day, country: country, completion: completeWith)
				}
			} else {
				// no error, no retry - clean up
				retries[url] = nil
			}
		}

		session.GET(url) { result in
			switch result {
			case let .success(response):
				guard let hourData = response.body else {
					responseError = .invalidResponse
					return
				}
				Log.info("got hour: \(hourData.count)", log: .api)
				guard let package = SAPDownloadedPackage(compressedData: hourData) else {
					Log.error("Failed to create signed package. For URL: \(url)", log: .api)
					responseError = .invalidResponse
					return
				}
				completeWith(.success(package))
			case let .failure(error):
				responseError = error
				Log.error("failed to get day: \(error)", log: .api)
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: SAPDownloadedPackage]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			self.fetchHour(hour, day: day, country: country) { result in
				switch result {
				case let .success(hourBucket):
					buckets[hour] = hourBucket
				case let .failure(error):
					errors.append(error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completeWith(
				HoursResult(errors: errors, bucketsByHour: buckets, day: day)
			)
		}
	}

	// MARK: - Private

	private let configuration: HTTPClient.Configuration
	private let session: URLSession
	private var retries: [URL: Int] = [:]

}
