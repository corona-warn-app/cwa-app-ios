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

public enum UserNotificationAction: String {
	case openExposureDetectionResults = "View_Exposure_Detection_Results"
	case openTestResults = "View_Test_Results"
	case ignore = "Ignore"
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
				logError(message: error.localizedDescription)
			}
		}

		let openActionIdentifier = UserNotificationAction.openExposureDetectionResults

		let viewAction = UNNotificationAction(
			identifier: openActionIdentifier.rawValue,
			title: openActionIdentifier.rawValue,
			options: [.authenticationRequired]
		)

		let deleteAction = UNNotificationAction(
			identifier: UserNotificationAction.ignore.rawValue,
			title: UserNotificationAction.ignore.rawValue,
			options: [.destructive]
		)

		let category = UNNotificationCategory(
			identifier: identifier,
			actions: [viewAction, deleteAction],
			intentIdentifiers: [],
			options: []
		)

		setNotificationCategories([category])

	}
}
