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
	
	// MARK: - Public
	
	/// Schedule a local notification to fire 2 hours if users has not warn to others. Scedule one more notification after 4 hours if still user has not share the keys.
	func scheduleWarnOthersNotifications(timerOne: Int, timerTwo: Int) {
		
		// Setup the notifications
		createWarnOtherNotification(notification: 1, timer: Double(timerOne))
		createWarnOtherNotification(notification: 2, timer: Double(timerTwo))
	}
	
	/// Cancels the Warn Others Notificatoin
	func cancelWarnOthersNotification() {
		removePendingNotificationRequests(withIdentifiers: [getUniqueWarnOthersNotificationIdentifier(notification: 1), getUniqueWarnOthersNotificationIdentifier(notification: 2)])
	}
	
	// MARK: - Private
	private func getUniqueWarnOthersNotificationIdentifier(notification: Int) -> String {
		return (Bundle.main.bundleIdentifier ?? "") + ".notifications.cwa-warnOthers-\(notification)"
	}
	
	// (PUM)
	private func createWarnOtherNotification(notification: Int, timer: Double) {
		UNUserNotificationCenter.current().presentNotification(title: AppStrings.WarnOthersNotification.title, body: AppStrings.WarnOthersNotification.description, identifier: getUniqueWarnOthersNotificationIdentifier(notification: notification), in: timer)
	
		}
}
