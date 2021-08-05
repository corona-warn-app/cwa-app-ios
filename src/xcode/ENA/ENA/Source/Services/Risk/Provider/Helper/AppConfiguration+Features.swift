//
// 🦠 Corona-Warn-App
//

/// App Feature with matching string label name
///
extension SAP_Internal_V2_ApplicationConfigurationIOS {

	/// list of known app features
	enum AppFeature: String {
		case disableDeviceTimeCheck = "disable-device-time-check"
		case unencryptedCheckinsEnabled = "unencrypted-checkins-enabled"
	}
}

protocol AppFeatureProviding {
	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool
}

class AppFeatureProvider: AppFeatureProviding {

	// MARK: - Init
	init(
		appConfiguration: AppConfigurationProviding
	) {
		self.appConfiguration = appConfiguration
	}

	// MARK: - Protocol AppFeaturesProviding

	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool {
		guard let configuration = appConfiguration?.currentAppConfig.value else {
			return false
		}
		let feature = configuration.appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}

	// MARK: - Private

	private weak var appConfiguration: AppConfigurationProviding?

}
