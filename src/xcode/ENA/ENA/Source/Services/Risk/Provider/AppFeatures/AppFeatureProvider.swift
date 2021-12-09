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

	func boolValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		if let configuration = appConfigurationProvider?.currentAppConfig.value {
			return boolValue(for: appFeature, from: configuration)
		} else if let configuration = appConfig {
			return boolValue(for: appFeature, from: configuration)
		} else {
			return appFeature.defaultValue == 1
		}
	}

	func intValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Int {
		if let configuration = appConfigurationProvider?.currentAppConfig.value {
			return intValue(for: appFeature, from: configuration)
		} else if let configuration = appConfig {
			return intValue(for: appFeature, from: configuration)
		} else {
			return appFeature.defaultValue
		}
	}

	// MARK: - Private

	private weak var appConfigurationProvider: AppConfigurationProviding?
	private var appConfig: SAP_Internal_V2_ApplicationConfigurationIOS?

	private func boolValue(
		for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature,
		from config: SAP_Internal_V2_ApplicationConfigurationIOS
	) -> Bool {
		let feature = config.appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}

	private func intValue(
		for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature,
		from config: SAP_Internal_V2_ApplicationConfigurationIOS
	) -> Int {
		guard let feature = config.appFeatures.appFeatures.first(where: {
			$0.label == appFeature.rawValue
		}) else {
			return appFeature.defaultValue
		}

		return Int(feature.value)
	}
	
}
