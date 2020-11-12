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
import ZIPFoundation

final class CachedAppConfiguration {

	enum CacheError: Error {
		case dataFetchError(message: String?)
		case dataVerificationError(message: String?)
		/// HTTP 304 – Content on server has not changed from the given `If-None-Match` header in the request
		case notModified
	}

	/// A reference to the key package store to directly allow removal of invalidated key packages
	weak var packageStore: DownloadedPackagesStore?

	/// Most likely a HTTP client
	private let client: AppConfigurationFetching

	/// The place where the app config and last etag is stored
	private let store: AppConfigCaching

	private let deviceTimeCheck: DeviceTimeCheckProtocol

	private let configurationDidChange: (() -> Void)?

	private var defaultAppConfigPath: URL? {
		Bundle.main.url(forResource: "default_app_config_17", withExtension: "")
	}

	init(
		client: AppConfigurationFetching,
		store: Store,
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

	private func fetchConfig(with etag: String?, completion: Completion? = nil) {
		client.fetchAppConfiguration(etag: etag) { [weak self] result in
			guard let self = self else { return }

			switch result.0 /* fyi, `result.1` would be the server time */{
			case .success(let response):
				self.store.lastAppConfigETag = response.eTag
				self.store.appConfig = response.config
				self.completeOnMain(completion: completion, result: .success(response.config))

				// keep track of last successful fetch
				self.store.lastAppConfigFetch = Date()

				// update revokation list
				let revokationList = self.store.appConfig?.revokationEtags ?? []
				self.packageStore?.revokationList = revokationList // for future package-operations
				// validate currently stored key packages
				do {
					try self.packageStore?.validateCachedKeyPackages(revokationList: revokationList)
				} catch {
					Log.error("Error while removing invalidated key packages.", log: .localData, error: error)
					// no further action - yet
				}

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

					// server response HTTP 304 is considered a 'successful fetch'
					self.store.lastAppConfigFetch = Date()
				default:
					// try to provide the default configuration or return error response
					guard
						let url = self.defaultAppConfigPath,
						let data = try? Data(contentsOf: url),
						let zip = Archive(data: data, accessMode: .read),
						let defaultConfig = try? zip.extractAppConfiguration()
					else {
						assertionFailure("Should not happen. Check config deserialization!")
						Log.error("Providing default app configuration failed! Initial HTTP error: \(error)")
						self.store.lastAppConfigETag = nil
						self.store.lastAppConfigFetch = nil
						self.completeOnMain(completion: completion, result: .failure(error))
						return
					}
					// Let's stick to the default for 5 Minutes
					// If you don't wanto to do this, nil out `lastAppConfigETag`
					self.store.lastAppConfigETag = "default"
					self.store.appConfig = defaultConfig
					self.store.lastAppConfigFetch = Date()

					Log.info("Providing canned app configuration 🥫", log: .localData)
					self.completeOnMain(completion: completion, result: .success(defaultConfig))
				}
			}

			if let serverTime = result.1 {
				self.deviceTimeCheck.updateDeviceTimeFlags(
					serverTime: serverTime,
					deviceTime: Date()
				)
			} else {
				self.deviceTimeCheck.resetDeviceTimeFlags()
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
        Log.debug("[Cache-Control] timestamp >= 300s? \(abs(lastFetch.distance(to: Date())) >= 300)", log: .localData)
        return abs(lastFetch.distance(to: Date())) >= 300
	}
}
