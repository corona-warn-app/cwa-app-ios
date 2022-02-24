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
		case validationServiceMinVersionMajor = "validation-service-ios-min-version-major"
		case validationServiceMinVersionMinor = "validation-service-ios-min-version-minor"
		case validationServiceMinVersionPatch = "validation-service-ios-min-version-patch"
		case dccPersonCountMax = "dcc-person-count-max"
		case dccPersonWarnThreshold = "dcc-person-warn-threshold"
		case cclAdmissionCheckScenariosDisabled = "ccl-admission-check-scenarios-disabled"

		var defaultValue: Int {
			switch self {
			case .disableDeviceTimeCheck:
				return 0
			case .unencryptedCheckinsEnabled:
				return 0
			case .validationServiceMinVersionMajor:
				return 0
			case .validationServiceMinVersionMinor:
				return 0
			case .validationServiceMinVersionPatch:
				return 0
			case .dccPersonCountMax:
				return 20
			case .dccPersonWarnThreshold:
				return 10
			case .cclAdmissionCheckScenariosDisabled:
				return 0
			}
		}
	}
}

protocol AppFeatureProviding {
	func boolValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Bool
	func intValue(for appFeature: SAP_Internal_V2_ApplicationConfigurationIOS.AppFeature) -> Int
}
