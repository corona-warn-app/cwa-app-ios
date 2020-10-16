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

import UserNotifications

extension UNUserNotificationCenter {

	// MARK: - Internal
	
	/// Schedules a local notification to fire 36 hours from now, if there isn´t a notification already scheduled
	func scheduleDeadmanNotificationIfNeeded() {
		
		// Check if Deadman Notification is already scheduled
		getPendingNotificationRequests(completionHandler: { notificationRequests in
			if notificationRequests.contains(where: { $0.identifier == UNUserNotificationCenter.deadmanNotificationIdentifier }) {
				// Deadman Notification already setup -> return
				return
			} else {
				// No Deadman Notification setup, contiune to setup a new one
				let content = UNMutableNotificationContent()
				content.title = AppStrings.Common.deadmanAlertTitle
				content.body = AppStrings.Common.deadmanAlertBody
				content.sound = .default
				
				let trigger = UNTimeIntervalNotificationTrigger(
					timeInterval: 36 * 60 * 60,
					repeats: false
				)
				
				let request = UNNotificationRequest(
					identifier: UNUserNotificationCenter.deadmanNotificationIdentifier,
					content: content,
					trigger: trigger
				)
				
				self.add(request) { error in
					if error != nil {
						logError(message: "Deadman notification could not be scheduled.")
					}
				}
			}
		})
	}
	
	/// Reset the Deadman Notification, should be called after a successfull risk-calculation.
	func resetDeadmanNotification() {
		cancelDeadmanNotification()
		scheduleDeadmanNotificationIfNeeded()
	}
	
	// MARK: - Private
	
	private static let deadmanNotificationIdentifier = (Bundle.main.bundleIdentifier ?? "") + ".notifications.cwa-deadman"

	/// Cancels the Deadman Notificatoin
	private func cancelDeadmanNotification() {
		removePendingNotificationRequests(withIdentifiers: [UNUserNotificationCenter.deadmanNotificationIdentifier])
	}
}
