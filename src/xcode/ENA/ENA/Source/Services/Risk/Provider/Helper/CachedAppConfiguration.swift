//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import ZIPFoundation

final class CachedAppConfiguration {

	// MARK: - Init

	init(
		client: AppConfigurationFetching,
		store: Store,
		deviceTimeCheck: DeviceTimeCheckProtocol? = nil
	) {
		Log.debug("CachedAppConfiguration init called", log: .appConfig)

		self.client = client
		self.store = store

		self.deviceTimeCheck = deviceTimeCheck ?? DeviceTimeCheck(store: store)

		guard shouldFetch() else { return }

		// check for updated or fetch initial app configuration
		getAppConfig(with: store.appConfigMetadata?.lastAppConfigETag)
			.sink(receiveValue: { _ in })
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum CacheError: Error {
		case dataFetchError(message: String?)
		case dataVerificationError(message: String?)
	}

	/// A reference to the key package store to directly allow removal of invalidated key packages
	weak var packageStore: DownloadedPackagesStore?


	// MARK: - Private

	private struct AppConfigResponse {
		let config: SAP_Internal_V2_ApplicationConfigurationIOS
		let etag: String?
	}

	/// Most likely a HTTP client
	private let client: AppConfigurationFetching

	/// The place where the app config and last etag is stored
	private let store: AppConfigCaching
	private let deviceTimeCheck: DeviceTimeCheckProtocol

	private var subscriptions = [AnyCancellable]()

	/// The location of the default app configuration.
	private var defaultAppConfigPath: URL {
		guard let url = Bundle.main.url(forResource: "default_app_config_113", withExtension: "") else {
			fatalError("Could not locate default app config")
		}
		return url
	}

	private var promises = [(Result<CachedAppConfiguration.AppConfigResponse, Never>) -> Void]()
	private var requestIsRunning: Bool { !promises.isEmpty }

	private static let queue = DispatchQueue(label: "fetchAppConfiguration queue", qos: .userInitiated, attributes: .concurrent)

	private func getAppConfig(with etag: String? = nil) -> Future<AppConfigResponse, Never> {
		return Future { promise in
			Self.queue.sync(flags: .barrier) {
				guard !self.requestIsRunning else {
					Log.debug("Return immediately because request allready running.", log: .appConfig)
					Log.debug("Append promise.", log: .appConfig)
					self.promises.append(promise)
					return
				}

				Log.debug("Append promise.", log: .appConfig)
				self.promises.append(promise)

				self.client.fetchAppConfiguration(etag: etag) { [weak self] result in
					guard let self = self else { return }
                    var updatedSuccessful = true

					switch result.0 {
					case .success(let response):
						self.store.appConfigMetadata = AppConfigMetadata(
							lastAppConfigETag: response.eTag ?? "\"ReloadMe\"",
							lastAppConfigFetch: Date(),
							appConfig: response.config
						)

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
						self.resolvePromises(with: .success(AppConfigResponse(config: response.config, etag: response.eTag)))

					case .failure(let error):
						switch error {
						case URLSessionError.notModified where self.store.appConfigMetadata != nil:
							Log.error("config not modified", log: .api)
							// server is not modified and we have a cached config
							guard let meta = self.store.appConfigMetadata else {
								fatalError("App configuration cache broken!") // in `where` we trust
							}
							// server response HTTP 304 is considered a 'successful fetch'
							self.store.appConfigMetadata?.refeshLastAppConfigFetchDate()
							self.resolvePromises(with: .success(AppConfigResponse(config: meta.appConfig, etag: meta.lastAppConfigETag)))
						default:
							self.defaultFailureHandler()
                            updatedSuccessful = false
						}
					}

					// time check ⌚️
					if let serverTime = result.1 {
						self.deviceTimeCheck.updateDeviceTimeFlags(
							serverTime: serverTime,
							deviceTime: Date(),
							configUpdateSuccessful: updatedSuccessful
						)
					} else {
						self.deviceTimeCheck.resetDeviceTimeFlags(configUpdateSuccessful: false)
					}
				} // eo fetch
			} // eo async
		}
	}

	private func defaultFailureHandler() {
		// Try to provide the cached app config.
		if let cachedAppConfig = self.store.appConfigMetadata {
			Log.info("Providing cached app configuration", log: .localData)
			resolvePromises(with: .success(AppConfigResponse(config: cachedAppConfig.appConfig, etag: cachedAppConfig.lastAppConfigETag)))
			return
		}

		// If there is no cached config, provide the default configuration.
		guard
			let data = try? Data(contentsOf: self.defaultAppConfigPath),
			let zip = Archive(data: data, accessMode: .read),
			let defaultConfig = try? zip.extractAppConfiguration()
		else {
			Log.error("Could not provide static app configuration!", log: .localData, error: nil)
			fatalError("Could not provide static app configuration!")
		}

		Log.info("Providing default app configuration 🥫", log: .localData)
		resolvePromises(with: .success(AppConfigResponse(config: defaultConfig, etag: self.store.appConfigMetadata?.lastAppConfigETag)))
	}

	private func resolvePromises(with result: Result<CachedAppConfiguration.AppConfigResponse, Never>) {
		Log.debug("resolvePromises count: \(self.promises.count).", log: .appConfig)

		for promise in self.promises {
			promise(result)
		}
		self.promises = [(Result<CachedAppConfiguration.AppConfigResponse, Never>) -> Void]()
	}
}

extension CachedAppConfiguration: AppConfigurationProviding {

	fileprivate static let timestampKey = "LastAppConfigFetch"

	func appConfiguration(forceFetch: Bool = false) -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		let force = shouldFetch() || forceFetch

		if let cachedVersion = store.appConfigMetadata?.appConfig, !force {
			Log.debug("fetching cached app configuration", log: .appConfig)
			// use the cached version
			return Just(cachedVersion)
				.receive(on: DispatchQueue.main.ocombine)
				.eraseToAnyPublisher()
		} else {
			Log.debug("fetching fresh app configuration. forceFetch: \(forceFetch), force: \(force)", log: .appConfig)
			// fetch a new one
			return getAppConfig(with: store.appConfigMetadata?.lastAppConfigETag)
				.receive(on: DispatchQueue.main.ocombine)
				.map({ $0.config })
				.eraseToAnyPublisher()
		}
	}

	func appConfiguration() -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		return appConfiguration(forceFetch: false)
	}

	func supportedCountries() -> AnyPublisher<[Country], Never> {
		return appConfiguration()
			.map({ config -> [Country] in
				let countries = config.supportedCountries.compactMap({ Country(countryCode: $0) })
				return countries.isEmpty ? [.defaultCountry()] : countries
			})
			.eraseToAnyPublisher()
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
		Log.debug("timestamp >= 300s? \(abs(Date().timeIntervalSince(lastFetch))) >= 300)", log: .appConfig)
        return abs(Date().timeIntervalSince(lastFetch)) >= 300
	}
}
