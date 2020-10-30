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

	private let deviceTimeCheck: DeviceTimeCheckProtocol

	private let configurationDidChange: (() -> Void)?

	init(
		client: AppConfigurationFetching,
		store: AppConfigCaching,
		deviceTimeCheck: DeviceTimeCheckProtocol? = nil,
		configurationDidChange: (() -> Void)? = nil
	) {
		self.client = client
		self.store = store
		self.configurationDidChange = configurationDidChange

		self.deviceTimeCheck = deviceTimeCheck ?? DeviceTimeCheck(store: store)

		guard shouldFetch() else { return }

		// edge case: if no app config is cached, omit a potentially existing ETag to force fetch a new configuration
		let etag = store.appConfig == nil ? nil : store.lastAppConfigETag

		// check for updated or fetch initial app configuration
		fetchConfig(with: etag)
	}

	private func fetchConfig(with etag: String?, compltanetion: Completion? = nil) {
		client.fetchAppConfiguration(etag: etag) { [weak self] result in
			guard let self = self else { return }

			switch result.0 {
			case .success(let response):
				self.store.lastAppConfigETag = response.eTag
				self.store.appConfig = response.config
				self.completeOnMain(completion: completion, result: .success(response.config))

				// keep track of last successful fetch
				self.store.lastAppConfigFetch = Date()

				self.configurationDidChange?()
			case .failure(let error):
				switch error {
				case CachedAppConfiguration.CacheError.notModified where self.store.appConfig != nil:
					Log.error("config not modified", log: .api)
					// server is not modified and we have a cached config
					guard let config = self.store.appConfig else {
						fatalError("App configuration cache broken!") // in `where` we trust
					}
					self.completeOnMain(completion: completion, result: .success(config))

					// keep track of last successful fetch
					self.store.lastAppConfigFetch = Date()
				default:
					self.completeOnMain(completion: completion, result: .failure(error))
				}
			}

			if let serverTime = result.1 {
				self.deviceTimeCheck.checkAndPersistDeviceTimeFlags(
					serverTime: serverTime,
					deviceTime: Date()
				)
			} else {
				self.deviceTimeCheck.resetDeviceTimeFlagsToDefault()
			}
		}
	}

	// Prevents failing main thread checks because UI is accessing the result directly.
	private func completeOnMain(completion: Completion?, result: Result<SAP_ApplicationConfiguration, Error>) {
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
			// use the cached version
			completeOnMain(completion: completion, result: .success(cachedVersion))
		} else {
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
		guard let lastFetch = store.lastAppConfigFetch else {
			return true
		}
		return abs(lastFetch.distance(to: Date())) >= 300
	}
}
