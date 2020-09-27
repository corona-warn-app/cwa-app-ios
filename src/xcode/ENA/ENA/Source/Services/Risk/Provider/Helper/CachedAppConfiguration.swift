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

final class CachedAppConfiguration {

	enum CacheError: Error {
		case dataFetchError(message: String?)
		case dataVerificationError(message: String?)
		/// HTTP 304 – Content on server has not changed from the given `If-None-Match` header in the request
		case notModified
	}

	/// Most likely a HTTP client
	private let client: AppConfigurationFetching

	/// The place where the app config and last etag is stored
	private let store: AppConfigCaching

	init(client: AppConfigurationFetching, store: AppConfigCaching) {
		self.client = client
		self.store = store

		// edge case: if no app config is cached, omit a potentially existing ETag to force fetch a new configuration
		let etag = store.appConfig == nil ? nil : store.lastETag

		// check for updated or fetch initial app configuration
		fetchConfig(with: etag)
	}

	private func fetchConfig(with etag: String?, completion: Completion? = nil) {
		client.fetchAppConfiguration(etag: etag) { [weak self] result in
			switch result {
			case .success(let response):
				self?.store.lastETag = response.eTag
				self?.store.appConfig = response.config
				completion?(.success(response.config))
			case .failure(let error):
				switch error {
				case CachedAppConfiguration.CacheError.notModified where self?.store.appConfig != nil:
					log(message: "config not modified")
					// server is not modified and we have a cached config
					guard let config = self?.store.appConfig else {
						fatalError("App configuration cache broken!") // in `where` we trust
					}
					completion?(.success(config))
				default:
					completion?(.failure(error))
				}
			}
		}
	}
}

extension CachedAppConfiguration: AppConfigurationProviding {

	func appConfiguration(forceFetch: Bool = false, completion: @escaping Completion) {
		if let cachedVersion = store.appConfig, !forceFetch {
			// use the cached version
			completion(.success(cachedVersion))
		} else {
			// fetch a new one
			fetchConfig(with: store.lastETag, completion: completion)
		}
	}

	func appConfiguration(completion: @escaping Completion) {
		self.appConfiguration(forceFetch: false, completion: completion)
	}
}
