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

import Foundation


class CachingHTTPClient: AppConfigurationFetching {
	/// The client configuration - mostly server endpoints per environment
	let configuration: HTTPClient.Configuration

	/// The underlying URLSession for all network requests
	let session: URLSession

	/// Verifier for the fetched & signed protobuf packages
	let packageVerifier: SAPDownloadedPackage.Verifier


	/// Initializer for the caching client.
	///
	/// - Parameters:
	///   - clientConfiguration: The client configuration for the client.
	///   - session: An optional session to use for network requests. Default is based on a predefined configuration.
	///   - packageVerifier: The verifier to use for package validation.
	init(
		clientConfiguration: HTTPClient.Configuration,
		session: URLSession = URLSession(configuration: .cachingSessionConfiguration()),
		packageVerifier: SAPDownloadedPackage.Verifier = SAPDownloadedPackage.Verifier()) {
		self.session = session
		self.configuration = clientConfiguration
		self.packageVerifier = packageVerifier
	}

	// MARK: - AppConfigurationFetching

	/// Fetches an application configuration file
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchAppConfiguration(etag: String? = nil, completion: @escaping AppConfigResultHandler) {
		// ETag
		var headers: [String: String]?
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.configurationURL, extraHeaders: headers) { result in
			switch result {
			case .success(let response):

				if let dateString = response.httpResponse.value(forHTTPHeaderField: "Date") {
					// "Thu, 22 Oct 2020 13:59:00 GMT"
					let dateFormatter = DateFormatter()
					dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"

					if let serverDate = dateFormatter.date(from: dateString),
					   let serverDateMinus2Hours = Calendar.current.date(byAdding: .hour, value: -2, to: serverDate),
					   let serverDatePlus2Hours = Calendar.current.date(byAdding: .hour, value: 2, to: serverDate) {
							let deviceDate = Date()
							let deviceTimeIsCorrect = (serverDateMinus2Hours ... serverDatePlus2Hours).contains(deviceDate)
							print(deviceTimeIsCorrect)
					}

					//(server_time - 2 hrs) < device_time_in_utc < (server_time + 2 hrs)
				}

				// content not modified?
				guard response.statusCode != 304 else {
					completion(.failure(CachedAppConfiguration.CacheError.notModified))
					return
				}

				// has data?
				guard
					let data = response.body,
					let package = SAPDownloadedPackage(compressedData: data)
				else {
					let error = CachedAppConfiguration.CacheError.dataFetchError(message: "Failed to create downloaded package for app config.")
					completion(.failure(error))
					return
				}

				// data verified?
				guard self.packageVerifier(package) else {
					let error = CachedAppConfiguration.CacheError.dataVerificationError(message: "Failed to verify app config signature")
					completion(.failure(error))
					return
				}

				// serialize config
				do {
					let config = try SAP_ApplicationConfiguration(serializedData: package.bin)
					let eTag = response.httpResponse.value(forHTTPHeaderField: "ETag")
					let configurationResponse = AppConfigurationFetchingResponse(config, eTag)
					completion(.success(configurationResponse))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
