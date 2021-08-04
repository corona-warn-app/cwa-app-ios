//
// 🦠 Corona-Warn-App
//

/// App Feature helpers to determine if a feature is enabled or disabled
///
extension SAP_Internal_V2_ApplicationConfigurationIOS {

	/// list of known app features
	enum AppFeature: String {
		case disableDeviceTimeCheck = "disable-device-time-check"
		case unencryptedCheckinsEnabled = "unencrypted-checkins-enabled"
	}

	/// helper for bool values
	func value(for appFeature: AppFeature) -> Bool {
		let feature = appFeatures.appFeatures.first {
			$0.label == appFeature.rawValue
		}
		return feature?.value == 1
	}
}
