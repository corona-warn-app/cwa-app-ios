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
		switch appFeature {
		case .isTicketValidationEnabled(let currentAppVersion):
			if let configuration = appConfigurationProvider?.currentAppConfig.value {
				return isTicketValidationEnabled(currentVersion: Version, from: configuration)
			} else if let configuration = appConfig {
				return isTicketValidationEnabled(currentVersion: Version, from: configuration)
			} else {
				return false
			}
		default:
			if let configuration = appConfigurationProvider?.currentAppConfig.value {
				return value(for: appFeature, from: configuration)
			} else if let configuration = appConfig {
				return value(for: appFeature, from: configuration)
			} else {
				return false
			}
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
	
	private func isTicketValidationEnabled(
		currentVersion: Version,
		from config: SAP_Internal_V2_ApplicationConfigurationIOS
	) {
		let major = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-major"
		}
		let minor = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-minor"
		}
		let patch = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-patch"
		}
	}
}
