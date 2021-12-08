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
		case isTicketValidationEnabled = "isTicketValidationEnabled"
//		case validationServiceMinVersionMajor = "validation-service-ios-min-version-major"
//		case validationServiceMinVersionMinor = "validation-service-ios-min-version-minor"
//		case validationServiceMinVersionPatch = "validation-service-ios-min-version-patch"
	}
}

/// protocol an AppFeature provider must fulfill
///
protocol AppFeatureProviding {
	func value(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool
}
