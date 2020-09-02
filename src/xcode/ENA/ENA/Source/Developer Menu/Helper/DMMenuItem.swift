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
	case checkSubmittedKeys
	case backendConfiguration
	case lastSubmissionRequest
	case lastRiskCalculation
	case settings
	case manuallyRequestRisk
	case errorLog
	case purgeRegistrationToken
	case sendFakeRequest
	case store
	case tracingHistory
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
		case .checkSubmittedKeys: return "Check submitted Keys"
		case .backendConfiguration: return "Backend Configuration"
		case .lastSubmissionRequest: return "Last Submission Request"
		case .lastRiskCalculation: return "Last Risk Calculation"
		case .settings: return "Developer Settings"
		case .manuallyRequestRisk: return "Manually Request Risk"
		case .errorLog: return "Error Log"
		case .purgeRegistrationToken: return "Purge Registration Token"
		case .sendFakeRequest: return "Send fake Request"
		case .store: return "Store Contents"
		case .tracingHistory: return "Tracing History"
		}
	}
	var subtitle: String {
		switch self {
		case .keys: return "View local Keys & generate test Keys"
		case .checkSubmittedKeys: return "Check the state of your local keys"
		case .backendConfiguration: return "See the current backend configuration"
		case .lastSubmissionRequest: return "Export the last executed submission request"
		case .lastRiskCalculation: return "View and export the last executed risk calculation"
		case .settings: return "Adjust the Developer Settings (e.g: hourly mode)"
		case .manuallyRequestRisk: return "Manually requests the current risk"
		case .errorLog: return "View all errors logged by the app"
		case .purgeRegistrationToken: return "Purge Registration Token"
		case .sendFakeRequest: return "Sends a fake request for testing plausible deniability"
		case .store: return "See the contents of the encrypted store used by the app"
		case .tracingHistory: return "See when tracing was active"
		}
	}
}

#endif
