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
	}


	init(client: AppConfigurationFetching, store: AppConfigCaching) {
		self.client = client
		self.store = store

		// check for updated or fetch initial app configuration
		client.fetchAppConfiguration(etag: store.lastETag) { result in
			switch result {
			case .success(let response):
				self.store.lastETag = response.eTag
				self.store.appConfig = response.config
			case .failure(let error):
				logError(message: "Failed to fetch app config: \(error.localizedDescription)")
			}
		}
	}

	/// Most likely a HTTP client
	private let client: AppConfigurationFetching

	/// The place where the app config and last etag is stored
	private let store: AppConfigCaching

}

extension CachedAppConfiguration: AppConfigurationProviding {

	func appConfiguration(forceFetch: Bool = false, completion: @escaping Completion) {
		if let cachedVersion = store.appConfig, !forceFetch {
			// use the cached version
			completion(.success(cachedVersion))
		} else {
			// fetch a new one
			client.fetchAppConfiguration(etag: store.lastETag) { [weak self] result in
				switch result {
				case .success(let response):
					self?.store.lastETag = response.eTag
					self?.store.appConfig = response.config
					completion(.success(response.config))
				case .failure(let error):
					completion(.failure(error))
				}
			}
		}
	}

	func appConfiguration(completion: @escaping Completion) {
		self.appConfiguration(forceFetch: false, completion: completion)
	}
}
