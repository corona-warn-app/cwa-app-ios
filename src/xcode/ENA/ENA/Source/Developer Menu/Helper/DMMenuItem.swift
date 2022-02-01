//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

enum DMMenuItem: Int, CaseIterable {
	case cclConfig = 0
	case newHttp
	case ticketValidation
	case keys
	case wifiClient
	case checkSubmittedKeys
	case appConfiguration
	case backendConfiguration
	case lastSubmissionRequest
	case lastOnBehalfSubmissionRequest
	case manuallyRequestRisk
	case debugRiskCalculation
	case errorLog
	case els
	case sendFakeRequest
	case store
	case onboardingVersion
	case serverEnvironment
	case simulateNoDiskSpace
	case listPendingNotifications
	case warnOthersNotifications
	case deviceTimeCheck
	case ppacService
	case otpService
	case ppaMostRecent
	case ppaActual
	case ppaSubmission
	case installationDate
    case allTraceLocations
	case mostRecentTraceLocationCheckedInto
	case adHocPosterGeneration
	case appFeatures
	case dscLists
	case notifications
	case boosterRules
	
}

extension DMMenuItem {
	init?(indexPath: IndexPath) {
		self.init(rawValue: indexPath.row)
	}
	
	static func existingFromIndexPath(_ indexPath: IndexPath) -> DMMenuItem {
		guard let item = self.init(indexPath: indexPath) else {
			fatalError("Requested a menu item for an invalid index path. This is a programmer error.")
		}
		return item
	}
	
	var title: String {
		switch self {
		case .cclConfig: return "CCL Configuration"
		case .newHttp: return "New RestService - Only for DEVs"
		case .ticketValidation: return "Ticket validation service"
		case .keys: return "Keys"
		case .wifiClient: return "Hourly packages over Wifi only"
		case .checkSubmittedKeys: return "Check submitted Keys"
		case .appConfiguration: return "App Configuration"
		case .backendConfiguration: return "Backend Configuration"
		case .lastSubmissionRequest: return "Last Submission Request"
		case .lastOnBehalfSubmissionRequest: return "Last on behalf Submission"
		case .manuallyRequestRisk: return "Manually Request Risk"
		case .debugRiskCalculation: return "Debug Risk Calculation"
		case .errorLog: return "Error Log"
		case .els: return "ELS Options"
		case .sendFakeRequest: return "Send fake Request"
		case .store: return "Store Contents"
		case .onboardingVersion: return "Onboarding Version"
		case .serverEnvironment: return "Server Environment"
		case .simulateNoDiskSpace: return "Simulate SQLite Error"
		case .listPendingNotifications: return "Pending Notifications"
		case .warnOthersNotifications: return "Warn Others Notifications"
		case .deviceTimeCheck: return "Device Time Check"
		case .ppacService: return "PPAC Service / API Token"
		case .otpService: return "OTP Tokens"
		case .ppaMostRecent: return "PPA Most Recent Data"
		case .ppaActual: return "PPA Actual Data"
		case .ppaSubmission: return "PPA Submission"
		case .installationDate: return "Installation Date"
		case .allTraceLocations: return "All created trace locations"
		case .mostRecentTraceLocationCheckedInto: return "Most recent trace location checked into"
		case .adHocPosterGeneration: return "Ad-Hoc Poster Generation"
		case .appFeatures: return "App Features"
		case .dscLists: return "DSC Lists"
		case .notifications: return "Trigger Notifications"
		case .boosterRules: return "Download Booster rules"
		}
	}
	var subtitle: String {
		switch self {
		case .cclConfig: return "Download forced or not the ccl configuration"
		case .newHttp: return "New RestService - Only for DEVs"
		case .ticketValidation: return "Configure ticket validation service"
		case .keys: return "View local Keys & generate test Keys"
		case .wifiClient: return "Change hourly packages network connection type"
		case .checkSubmittedKeys: return "Check the state of your local keys"
		case .appConfiguration: return "See the current app configuration"
		case .backendConfiguration: return "See the current backend configuration"
		case .lastSubmissionRequest: return "Export the last executed submission request"
		case .lastOnBehalfSubmissionRequest: return "Export the last executed submission ob behalf request"
		case .manuallyRequestRisk: return "Manually requests the current risk"
		case .debugRiskCalculation: return "See the most recent risk calculation values"
		case .errorLog: return "View all errors logged by the app"
		case .els: return "Some options to control ELS settings"
		case .sendFakeRequest: return "Sends a fake request for testing plausible deniability"
		case .store: return "See the contents of the encrypted store used by the app"
		case .onboardingVersion: return "Set the onboarding version"
		case .serverEnvironment: return "Select server environment"
		case .simulateNoDiskSpace: return "Simulates SQLite returns defined error"
		case .listPendingNotifications: return "List all pending Notifications"
		case .warnOthersNotifications: return "Settings for the warn others notifications"
		case .deviceTimeCheck: return "Enable or Disable Device Time Check"
		case .ppacService: return "Inspect and force updates to the PPAC Token"
		case .otpService: return "Inspect the OTP Token for EDUS and ELS"
		case .ppaMostRecent: return "See the last successful submitted ppa data"
		case .ppaActual: return "See current analytics data as they were submitted now"
		case .ppaSubmission: return "Analytics data submission settings"
		case .installationDate: return "Installation date setup"
		case .allTraceLocations: return "See the data of the created trace locations"
		case .mostRecentTraceLocationCheckedInto: return "See the calculated ID of the trace location most recently checked into"
		case .adHocPosterGeneration: return "Generate QR code poster by providing the customized values"
		case .appFeatures: return "Override App Features here"
		case .dscLists: return "Change DSC Lists"
		case .notifications: return "Trigger Certificate notifications only"
		case .boosterRules: return "Download Booster rules and trigger the notification"
		}
	}
}

#endif
