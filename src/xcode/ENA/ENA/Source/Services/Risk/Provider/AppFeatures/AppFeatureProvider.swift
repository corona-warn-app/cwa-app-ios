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

	// MARK: - Protocol AppFeaturesProviding

	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		guard let configuration = appConfigurationProvider?.currentAppConfig.value else {
			return false
		}
		let feature = configuration.appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}

	// MARK: - Private

	private weak var appConfigurationProvider: AppConfigurationProviding?

}
