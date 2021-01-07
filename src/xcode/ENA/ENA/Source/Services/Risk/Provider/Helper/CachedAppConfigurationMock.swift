//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import ZIPFoundation

#if DEBUG
final class CachedAppConfigurationMock: AppConfigurationProviding {

	private let config: SAP_Internal_V2_ApplicationConfigurationIOS


	/// A special configuration for screenshots.
	///
	/// Provides a fake list of supported countries.
	static let screenshotConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS = {
		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.supportedCountries = ["DE", "ES", "FR", "IT", "IE", "DK"]
		return config
	}()


	/// The default app configration loaded directly from file.
	///
	///	This is synchronously for test and screenshot purposes. Use `AppConfigurationProviding` for 'real' config fetching!
	static let defaultAppConfiguration: SAP_Internal_V2_ApplicationConfigurationIOS = {
		guard
			let url = Bundle.main.url(forResource: "default_app_config_18", withExtension: ""),
			let data = try? Data(contentsOf: url),
			let zip = Archive(data: data, accessMode: .read),
			let staticConfig = try? zip.extractAppConfiguration() else {
			fatalError("Could not fetch static app config")
		}
		return staticConfig
	}()

	init(with config: SAP_Internal_V2_ApplicationConfigurationIOS = CachedAppConfigurationMock.defaultAppConfiguration) {
		self.config = config
	}

	func appConfiguration(forceFetch: Bool) -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		return Just(config)
			.receive(on: DispatchQueue.main.ocombine)
			.eraseToAnyPublisher()
	}

	func appConfiguration() -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		return appConfiguration(forceFetch: false)
	}

	func supportedCountries() -> AnyPublisher<[Country], Never> {
		appConfiguration().map({ config -> [Country] in
			let countries = config.supportedCountries.compactMap({ Country(countryCode: $0) })
			return countries.isEmpty ? [.defaultCountry()] : countries
		}).eraseToAnyPublisher()
	}
}
#endif
