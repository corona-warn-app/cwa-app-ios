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

import UserNotifications

public enum ActionableNotificationIdentifier: String {
	case testResult = "test-result"
	case riskDetection = "risk-detection"
	case deviceTimeCheck = "device-time-check"
	case warnOthersReminder1 = "warn-others-reminder-1"
	case warnOthersReminder2 = "warn-others-reminder-2"

	var identifier: String {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"
		return "\(bundleIdentifier).\(rawValue)"
	}
}

extension UNUserNotificationCenter {

	func presentNotification(
		title: String,
		body: String = "",
		identifier: String = UUID().uuidString,
		in timeInterval: TimeInterval = 1
	) {
		let content = UNMutableNotificationContent()

		content.title = title
		content.body = body
		content.sound = UNNotificationSound.default
		content.badge = 1
		content.categoryIdentifier = identifier

		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		add(request) { error in
			if let error = error {
				Log.error(error.localizedDescription, log: .api)
			}
		}
	}

}
