//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
#if !RELEASE

import Foundation

enum DMMenuItem: Int, CaseIterable {
	case keys = 0
	case wifiClient
	case checkSubmittedKeys
	case appConfiguration
	case backendConfiguration
	case lastSubmissionRequest
	case manuallyRequestRisk
	case debugRiskCalculation
	case errorLog
	case purgeRegistrationToken
	case sendFakeRequest
	case store
	case tracingHistory
	case onboardingVersion
	case serverEnvironment
	case simulateNoDiskSpace
	case listPendingNotifications
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
		case .keys: return "Keys"
		case .wifiClient: return "Hourly packages over Wifi only"
		case .checkSubmittedKeys: return "Check submitted Keys"
		case .appConfiguration: return "App Configuration"
		case .backendConfiguration: return "Backend Configuration"
		case .lastSubmissionRequest: return "Last Submission Request"
		case .manuallyRequestRisk: return "Manually Request Risk"
		case .debugRiskCalculation: return "Debug Risk Calculation"
		case .errorLog: return "Error Log"
		case .purgeRegistrationToken: return "Purge Registration Token"
		case .sendFakeRequest: return "Send fake Request"
		case .store: return "Store Contents"
		case .tracingHistory: return "Tracing History"
		case .onboardingVersion: return "Onboarding Version"
		case .serverEnvironment: return "Server Environment"
		case .simulateNoDiskSpace: return "Simulate SQLite Error"
		case .listPendingNotifications: return "Pending Notifications"
		}
	}
	var subtitle: String {
		switch self {
		case .keys: return "View local Keys & generate test Keys"
		case .wifiClient: return "Change hourly packages network connection type"
		case .checkSubmittedKeys: return "Check the state of your local keys"
		case .appConfiguration: return "See the current app configuration"
		case .backendConfiguration: return "See the current backend configuration"
		case .lastSubmissionRequest: return "Export the last executed submission request"
		case .manuallyRequestRisk: return "Manually requests the current risk"
		case .debugRiskCalculation: return "See the most recent risk calculation values"
		case .errorLog: return "View all errors logged by the app"
		case .purgeRegistrationToken: return "Purge Registration Token"
		case .sendFakeRequest: return "Sends a fake request for testing plausible deniability"
		case .store: return "See the contents of the encrypted store used by the app"
		case .tracingHistory: return "See when tracing was active"
		case .onboardingVersion: return "Set the onboarding version"
		case .serverEnvironment: return "Select server environment"
		case .simulateNoDiskSpace: return "Simulates SQLite returns defined error"
		case .listPendingNotifications: return "List all pending Notifications"
		}
	}
}

#endif
