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
		switch appFeature {
		case .isTicketValidationEnabled:
			return isTicketValidationEnabled(from: config)
		default:
			let feature = config.appFeatures.appFeatures.first {
				$0.label == appFeature.rawValue
			}
			return feature?.value == 1
		}
	}
	
	private func isTicketValidationEnabled(
		from config: SAP_Internal_V2_ApplicationConfigurationIOS
	) -> Bool {
		
		let major = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-major"
		}
		let minor = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-minor"
		}
		let patch = config.appFeatures.appFeatures.first {
			$0.label == "validation-service-ios-min-version-patch"
		}
		
		
		guard let currentSemanticAppVersion = Bundle.main.appVersion.semanticVersion else {
			return false
		}
		
		var minimumVersion = SAP_Internal_V2_SemanticVersion()
		minimumVersion.major = UInt32(major?.value ?? 0)
		minimumVersion.minor = UInt32(minor?.value ?? 0)
		minimumVersion.patch = UInt32(patch?.value ?? 0)
		
		return !(currentSemanticAppVersion < minimumVersion)
	}
	
}
