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
	let configuration: HTTPClient.Configuration
	let session: URLSession
	let packageVerifier: SAPDownloadedPackage.Verifier

	init(session: URLSession = URLSession(configuration: .cachingSessionConfiguration()), configuration: HTTPClient.Configuration = .backendBaseURLs, packageVerifier: SAPDownloadedPackage.Verifier = SAPDownloadedPackage.Verifier()) {
		self.session = session
		self.configuration = configuration
		self.packageVerifier = packageVerifier
	}

	convenience init(basedOn client: HTTPClient) {
		self.init(configuration: client.configuration)
	}

	// MARK: - AppConfigurationFetching

	/// Fetches an application configuration file
	/// - Parameters:
	///   - etag: an optional ETag to download only versions that differ the given tag
	///   - completion: result handler
	func fetchAppConfiguration(etag: String? = nil, completion: @escaping AppConfigResultHandler) {
		// ETag
		var headers: [String: String]? = nil
		if let etag = etag {
			headers = ["If-None-Match": etag]
		}

		session.GET(configuration.configurationURL, extraHeaders: headers) { result in
			switch result {
			case .success(let response):
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
					let c = AppConfigurationFetchingResponse(config, eTag)
					completion(.success(c))
				} catch {
					completion(.failure(error))
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}
