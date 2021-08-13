//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import ZIPFoundation

#if !RELEASE
final class CachedAppConfigurationMock: AppConfigurationProviding {

	var currentAppConfig: CurrentValueSubject<SAP_Internal_V2_ApplicationConfigurationIOS, Never>
	var featureProvider: AppFeatureProviding {
		AppFeatureProvider(appConfigurationProvider: self)
	}

	var deviceTimeCheck: DeviceTimeChecking {
		DeviceTimeCheck(store: store, appFeatureProvider: featureProvider)
	}

	private var config: SAP_Internal_V2_ApplicationConfigurationIOS

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
			let url = Bundle.main.url(forResource: "default_app_config_270", withExtension: ""),
			let data = try? Data(contentsOf: url),
			let zip = Archive(data: data, accessMode: .read),
			var staticConfig = try? zip.extractAppConfiguration() else {
			fatalError("Could not fetch static app config")
		}
		return staticConfig
	}()

	init(
		with config: SAP_Internal_V2_ApplicationConfigurationIOS = CachedAppConfigurationMock.defaultAppConfiguration,
		store: AppConfigCaching & DeviceTimeCheckStoring = MockTestStore()
	) {
		self.config = config
		self.currentAppConfig = CurrentValueSubject<SAP_Internal_V2_ApplicationConfigurationIOS, Never>(config)
		self.store = store
	}
	
	init(
		with config: SAP_Internal_V2_ApplicationConfigurationIOS = CachedAppConfigurationMock.defaultAppConfiguration,
		isEventSurveyEnabled: Bool,
		isEventSurveyUrlAvailable: Bool,
		store: AppConfigCaching & DeviceTimeCheckStoring = MockTestStore()
	) {
		self.config = config
		self.currentAppConfig = CurrentValueSubject<SAP_Internal_V2_ApplicationConfigurationIOS, Never>(config)
		self.store = store
		self.config.eventDrivenUserSurveyParameters = eventDrivenUserSurveyParametersEnabled(
			isEnabled: isEventSurveyEnabled,
			isCorrectURL: isEventSurveyUrlAvailable
		)
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

	private func eventDrivenUserSurveyParametersEnabled(isEnabled: Bool, isCorrectURL: Bool) -> SAP_Internal_V2_PPDDEventDrivenUserSurveyParametersIOS {
		var surveyParameters = SAP_Internal_V2_PPDDEventDrivenUserSurveyParametersIOS()
		surveyParameters.common.surveyOnHighRiskURL = isCorrectURL ? "https://www.test.de" : "https://w.test.de"
		surveyParameters.common.surveyOnHighRiskEnabled = isEnabled ? true : false
		return surveyParameters
	}

	private let store: AppConfigCaching & DeviceTimeCheckStoring
}
#endif
