//
// 🦠 Corona-Warn-App
//

import Foundation
import Combine
import ZIPFoundation

final class CachedAppConfiguration {

	enum CacheError: Error {
		case dataFetchError(message: String?)
		case dataVerificationError(message: String?)
		/// HTTP 304 – Content on server has not changed from the given `If-None-Match` header in the request
		case notModified
	}

	@Published var configuration: SAP_Internal_ApplicationConfiguration?

	/// A reference to the key package store to directly allow removal of invalidated key packages
	weak var packageStore: DownloadedPackagesStore?

	/// Most likely a HTTP client
	private let client: AppConfigurationFetching

	/// The place where the app config and last etag is stored
	private let store: AppConfigCaching

	private let deviceTimeCheck: DeviceTimeCheckProtocol

	private let configurationDidChange: (() -> Void)?

	private var subscriptions = [AnyCancellable]()

	/// The location of the default app configuration.
	private var defaultAppConfigPath: URL {
		guard let url = Bundle.main.url(forResource: "default_app_config_17", withExtension: "") else {
			fatalError("Could not locate default app config")
		}
		return url
	}

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
		getAppConfig(with: store.appConfigMetadata?.lastAppConfigETag)
			.sink { config in
				self.store.appConfig = config
			}
			.store(in: &subscriptions)
	}

	private func getAppConfig(with etag: String? = nil) -> Future<SAP_Internal_ApplicationConfiguration, Never> {
		return Future { promise in
			self.client.fetchAppConfiguration(etag: etag) { [weak self] result in
				guard let self = self else { return }

				switch result.0 /* fyi, `result.1` would be the server time */{
				case .success(let response):
					self.store.lastAppConfigETag = response.eTag
					self.store.appConfig = response.config
					promise(.success(response.config))

					// keep track of last successful fetch
					self.store.lastAppConfigFetch = Date()

					// update revokation list
					let revokationList = self.store.appConfigMetadata?.appConfig.revokationEtags ?? []
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
						// server response HTTP 304 is considered a 'successful fetch'
						self.store.lastAppConfigFetch = Date()
						promise(.success(config))

					default:
						// try to provide the default configuration or return error response
						guard
							let data = try? Data(contentsOf: self.defaultAppConfigPath),
							let zip = Archive(data: data, accessMode: .read),
							let defaultConfig = try? zip.extractAppConfiguration()
						else {
							Log.error("Could not provide static app configuration!", log: .localData, error: nil)
							fatalError("Could not provide static app configuration!")
						}
						// Let's stick to the default for 5 Minutes
						// If you don't wanto to do this, nil out `lastAppConfigETag`
						self.store.lastAppConfigETag = "default"
						self.store.appConfig = defaultConfig
						self.store.lastAppConfigFetch = Date()

						Log.info("Providing canned app configuration 🥫", log: .localData)
						promise(.success(defaultConfig))
					}
				}

				// time check ⌚️
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
	}
}

extension CachedAppConfiguration: AppConfigurationProviding {

	fileprivate static let timestampKey = "LastAppConfigFetch"

	func appConfiguration(forceFetch: Bool = false) -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never> {
		let force = shouldFetch() || forceFetch

		if let cachedVersion = store.appConfigMetadata, !force {
			Log.debug("fetching cached app configuration", log: .appConfig)
			// use the cached version
			return Just(cachedVersion)
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		} else {
			Log.debug("fetching fresh app configuration. forceFetch: \(forceFetch), force: \(force)", log: .appConfig)
			// fetch a new one
			return getAppConfig(with: store.appConfigMetadata?.lastAppConfigETag)
				.receive(on: DispatchQueue.main)
				.eraseToAnyPublisher()
		}
	}

	func appConfiguration() -> AnyPublisher<SAP_Internal_ApplicationConfiguration, Never> {
		return appConfiguration(forceFetch: false)
	}

	/// Simple helper to simulate Cache-Control
	/// - Note: This 300 second value is because of current handicaps with the HTTPClient architecture
	///   which does not easily return response headers. This requires further refactoring of `URLSession+Convenience.swift`.
	/// - Returns: `true` is a network call should be done; `false` if cache should be used
	private func shouldFetch() -> Bool {
		if store.appConfigMetadata == nil { return true }

		// naïve cache control
		guard let lastFetch = store.appConfigMetadata?.lastAppConfigFetch else {
			Log.debug("no last config fetch timestamp stored", log: .appConfig)
			return true
		}
        Log.debug("timestamp >= 300s? \(abs(lastFetch.distance(to: Date())) >= 300)", log: .appConfig)
        return abs(lastFetch.distance(to: Date())) >= 300
	}
}
