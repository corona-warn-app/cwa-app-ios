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
	func scheduleWarnOthersNotifications(timeIntervalOne: TimeInterval, timeIntervalTwo: TimeInterval) {
		presentNotification(identifier: ActionableNotificationIdentifier.warnOthersReminder1.identifier, in: timeIntervalOne)
		presentNotification(identifier: ActionableNotificationIdentifier.warnOthersReminder2.identifier, in: timeIntervalOne)
	}
	
	/// Cancels the Warn Others Notificatoin
	func cancelWarnOthersNotification() {
		removePendingNotificationRequests(withIdentifiers: [
			ActionableNotificationIdentifier.warnOthersReminder1.identifier,
			ActionableNotificationIdentifier.warnOthersReminder2.identifier
		])
	}
	
	// MARK: - Private
	
	private func presentNotification(identifier: String, in timeInterval: TimeInterval) {
		UNUserNotificationCenter.current()
			.presentNotification(
				title: AppStrings.WarnOthersNotification.title,
				body: AppStrings.WarnOthersNotification.description,
				identifier: identifier,
				in: timeInterval
			)
	}
}
