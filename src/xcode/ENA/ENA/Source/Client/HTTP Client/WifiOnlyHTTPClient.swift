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

final class WifiOnlyHTTPClient: ClientWifiOnly {

	// MARK: - Init

	init(
		configuration: HTTPClient.Configuration,
		session: URLSession = URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly())
	) {
		self.configuration = configuration
		self.session = session
		self.disableHourlyDownload = false
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
		var responseError: Client.Failure?

		session.GET(url) { [weak self] result in
			guard let self = self else {
				completeWith(.failure(.noResponse))
				return
			}

			defer {
				// no guard in defer!
				if let error = responseError {
					let retryCount = self.retries[url] ?? 0
					if retryCount > 2 {
						completeWith(.failure(error))
					} else {
						self.retries[url] = retryCount.advanced(by: 1)
						Log.debug("\(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
						self.fetchHour(hour, day: day, country: country, completion: completeWith)
					}
				} else {
					// no error, no retry - clean up
					self.retries[url] = nil
				}
			}

			#if !RELEASE
			guard !self.disableHourlyDownload else {
				responseError = .noResponse
				return
			}
			#endif

			switch result {
			case let .success(response):
				guard let hourData = response.body else {
					responseError = .invalidResponse
					return
				}
				Log.debug("got hour: \(hourData.count)", log: .api)
				guard let package = SAPDownloadedPackage(compressedData: hourData) else {
					Log.error("Failed to create signed package. For URL: \(url)", log: .api)
					responseError = .invalidResponse
					return
				}
				let etag = response.httpResponse.allHeaderFields["ETag"] as? String
				let payload = PackageDownloadResponse(package: package, etag: etag)
				completeWith(.success(payload))
			case let .failure(error):
				responseError = error

				Log.error("failed to get hour: \(error)", log: .api)
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	var disableHourlyDownload: Bool

	var isWifiOnlyActive: Bool {
		let wifiOnlyConfiguration = URLSessionConfiguration.coronaWarnSessionConfigurationWifiOnly()
		return session.configuration.allowsCellularAccess == wifiOnlyConfiguration.allowsCellularAccess &&
			session.configuration.allowsExpensiveNetworkAccess == wifiOnlyConfiguration.allowsExpensiveNetworkAccess &&
			session.configuration.allowsConstrainedNetworkAccess == wifiOnlyConfiguration.allowsConstrainedNetworkAccess
	}

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: PackageDownloadResponse]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			fetchHour(hour, day: day, country: country) { result in
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
	private var session: URLSession
	private var retries: [URL: Int] = [:]
}

#if !RELEASE
extension WifiOnlyHTTPClient {

	func updateSession(wifiOnly: Bool) {
		let sessionConfiguration: URLSessionConfiguration = wifiOnly ?
			.coronaWarnSessionConfigurationWifiOnly() :
			.coronaWarnSessionConfiguration()
		session.invalidateAndCancel()
		session = URLSession(configuration: sessionConfiguration)
	}

}
#endif
