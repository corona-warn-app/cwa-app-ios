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

	private let configurationDidChange: (() -> Void)?

	init(client: AppConfigurationFetching, store: AppConfigCaching, configurationDidChange: (() -> Void)? = nil) {
		self.client = client
		self.store = store
		self.configurationDidChange = configurationDidChange

		guard shouldFetch() else { return }

		// edge case: if no app config is cached, omit a potentially existing ETag to force fetch a new configuration
		let etag = store.appConfig == nil ? nil : store.lastAppConfigETag

		// check for updated or fetch initial app configuration
		fetchConfig(with: etag)
	}

	private func fetchConfig(with etag: String?, completion: Completion? = nil) {
		client.fetchAppConfiguration(etag: etag) { [weak self] result in
			switch result {
			case .success(let response):
				self?.store.lastAppConfigETag = response.eTag
				self?.store.appConfig = response.config
				self?.completeOnMain(completion: completion, result: .success(response.config))

				// keep track of last successful fetch
				self?.store.lastAppConfigFetch = Date()

				self?.configurationDidChange?()
			case .failure(let error):
				switch error {
				case CachedAppConfiguration.CacheError.notModified where self?.store.appConfig != nil:
					Log.error("config not modified", log: .api)
					// server is not modified and we have a cached config
					guard let config = self?.store.appConfig else {
						fatalError("App configuration cache broken!") // in `where` we trust
					}
					self?.completeOnMain(completion: completion, result: .success(config))
				default:
					// ensure reset
					self?.store.lastAppConfigETag = nil
					self?.store.lastAppConfigFetch = nil

					self?.completeOnMain(completion: completion, result: .failure(error))
				}
			}
		}
	}

	// Prevents failing main thread checks because UI is accessing the result directly.
	private func completeOnMain(completion: Completion?, result: Result<SAP_Internal_ApplicationConfiguration, Error>) {
		DispatchQueue.main.async {
			completion?(result)
		}
	}
}

extension CachedAppConfiguration: AppConfigurationProviding {

	fileprivate static let timestampKey = "LastAppConfigFetch"

	func appConfiguration(forceFetch: Bool = false, completion: @escaping Completion) {
		let force = shouldFetch() || forceFetch

		if let cachedVersion = store.appConfig, !force {
			Log.debug("[App Config] fetching cached app configuration", log: .localData)
			// use the cached version
			completeOnMain(completion: completion, result: .success(cachedVersion))
		} else {
			Log.debug("[App Config] fetching fresh app configuration", log: .localData)
			// fetch a new one
			fetchConfig(with: store.lastAppConfigETag, completion: completion)
		}
	}

	func appConfiguration(completion: @escaping Completion) {
		self.appConfiguration(forceFetch: false, completion: completion)
	}

	/// Simple helper to simulate Cache-Control
	/// - Note: This 300 second value is because of current handicaps with the HTTPClient architecture
	///   which does not easily return response headers. This requires further refactoring of `URLSession+Convenience.swift`.
	/// - Returns: `true` is a network call should be done; `false` if cache should be used
	private func shouldFetch() -> Bool {
		if store.appConfig == nil { return true }

		// naïve cache control
		guard let lastFetch = store.lastAppConfigFetch else {
			Log.debug("[Cache-Control] no last config fetch timestamp stored", log: .localData)
			return true
		}
		Log.debug("[Cache-Control] timestamp >= 300s? \(lastFetch.distance(to: Date()) >= 300)", log: .localData)
		return lastFetch.distance(to: Date()) >= 300
	}
}
