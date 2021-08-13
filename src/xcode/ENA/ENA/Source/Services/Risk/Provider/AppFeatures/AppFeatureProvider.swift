//
// 🦠 Corona-Warn-App
//

/// the default App Feature Provider to read simple values
///
class AppFeatureProvider: AppFeatureProviding {

	// MARK: - Init

	init(
		appConfigurationProvider: AppConfigurationProviding
	) {
		self.appConfigurationProvider = appConfigurationProvider
	}

	init(
		appConfig: SAP_Internal_V2_ApplicationConfigurationIOS
	) {
		self.appConfig = appConfig
	}

	// MARK: - Protocol AppFeaturesProviding

	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		if let configuration = appConfigurationProvider?.currentAppConfig.value {
			return value(for: appFeature, from: configuration)
		} else if let configuration = appConfig {
			return value(for: appFeature, from: configuration)
		} else {
			return false
		}
	}

	// MARK: - Private

	private weak var appConfigurationProvider: AppConfigurationProviding?
	private var appConfig: SAP_Internal_V2_ApplicationConfigurationIOS?

	private func value(
		for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature,
		from config: SAP_Internal_V2_ApplicationConfigurationIOS
	) -> Bool {

		let feature = config.appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}
}
