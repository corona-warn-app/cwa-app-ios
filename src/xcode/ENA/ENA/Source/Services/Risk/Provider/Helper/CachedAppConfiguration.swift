//
// 🦠 Corona-Warn-App
//

import Foundation

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

	init(
		client: AppConfigurationFetching,
		store: Store,
		deviceTimeCheck: DeviceTimeCheckProtocol? = nil,
		configurationDidChange: (() -> Void)? = nil
	) {
		Log.debug("CachedAppConfiguration init called", log: .appConfig)

		self.client = client
		self.store = store
		self.configurationDidChange = configurationDidChange

		self.deviceTimeCheck = deviceTimeCheck ?? DeviceTimeCheck(store: store)


		guard shouldFetch() else { return }

		// check for updated or fetch initial app configuration
		fetchConfig(with: store.appConfigMetadata?.lastAppConfigETag)
	}

	private func fetchConfig(with etag: String?, completion: Completion? = nil) {
		Log.debug("fetchConfig called with etag:\(etag ?? "nil")", log: .appConfig)

		client.fetchAppConfiguration(etag: etag) { [weak self] result in
			guard let self = self else { return }

			switch result.0 /* fyi, `result.1` would be the server time */{
			case .success(let response):
				let configMetadata = AppConfigMetadata(
					lastAppConfigETag: response.eTag ?? "\"ReloadMe\"",
					lastAppConfigFetch: Date(),
					appConfig: response.config
				)

				// Skip processing of config if it didn't change.
				guard self.store.appConfigMetadata?.lastAppConfigETag != configMetadata.lastAppConfigETag else {
					Log.debug("Skip processing app config, because it didn't change", log: .appConfig)
					self.completeOnMain(completion: completion, result: .success(response.config))
					return
				}

				Log.debug("Persist new app configuration", log: .appConfig)
				self.store.appConfigMetadata = configMetadata

				// update revokation list
				let revokationList = self.store.appConfigMetadata?.appConfig.revokationEtags ?? []
				self.packageStore?.revokationList = revokationList // for future package-operations
				// validate currently stored key packages
				do {
					try self.packageStore?.validateCachedKeyPackages(revokationList: revokationList)
				} catch {
					Log.error("Error while removing invalidated key packages.", log: .appConfig, error: error)
					// no further action - yet
				}

				self.completeOnMain(completion: completion, result: .success(response.config))

				self.configurationDidChange?()
			case .failure(let error):
				switch error {
				case CachedAppConfiguration.CacheError.notModified where self.store.appConfigMetadata != nil:
					Log.error("Config not modified", log: .appConfig)
					// server is not modified and we have a cached config
					guard var appConfigMetadata = self.store.appConfigMetadata else {
						fatalError("App configuration cache broken!") // in `where` we trust
					}

					// server response HTTP 304 is considered a 'successful fetch'
					Log.debug("Update lastAppConfigFetchDate of persisted app configuration", log: .appConfig)
					appConfigMetadata.refeshLastAppConfigFetchDate()
					self.store.appConfigMetadata = appConfigMetadata

					self.completeOnMain(completion: completion, result: .success(appConfigMetadata.appConfig))
				default:
					self.completeOnMain(completion: completion, result: .failure(error))
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
		Log.debug("Request app configuration forceFetch: \(forceFetch)", log: .appConfig)

		let force = shouldFetch() || forceFetch

		if let cachedVersion = store.appConfigMetadata, !force {
			Log.debug("fetching cached app configuration", log: .appConfig)
			// use the cached version
			completeOnMain(completion: completion, result: .success(cachedVersion.appConfig))
		} else {
			Log.debug("fetching fresh app configuration. forceFetch: \(forceFetch), force: \(force)", log: .appConfig)
			// fetch a new one
			fetchConfig(with: store.appConfigMetadata?.lastAppConfigETag, completion: completion)
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
		Log.debug("shouldFetch called", log: .appConfig)

		if store.appConfigMetadata == nil {
			Log.debug("store.appConfigMetadata is nil", log: .appConfig)
			return true
		}

		// naïve cache control
		guard let lastFetch = store.appConfigMetadata?.lastAppConfigFetch else {
			Log.debug("no last config fetch timestamp stored", log: .appConfig)
			return true
		}
        Log.debug("timestamp >= 300s? \(abs(lastFetch.distance(to: Date())) >= 300)", log: .appConfig)
        return abs(lastFetch.distance(to: Date())) >= 300
	}
}
