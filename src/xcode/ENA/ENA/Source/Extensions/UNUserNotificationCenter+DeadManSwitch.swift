//
// 🦠 Corona-Warn-App
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
				// No Deadman Notification setup, continue to setup a new one
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
						Log.error("Deadman notification could not be scheduled.")
					}
				}
			}
		})
	}
	
	/// Reset the Deadman Notification, should be called after a successful risk-calculation.
	func resetDeadmanNotification() {
		cancelDeadmanNotification()
		scheduleDeadmanNotificationIfNeeded()
	}
	
	// MARK: - Private
	
	private static let deadmanNotificationIdentifier = (Bundle.main.bundleIdentifier ?? "") + ".notifications.cwa-deadman"

	/// Cancels the Deadman Notification
	private func cancelDeadmanNotification() {
		removePendingNotificationRequests(withIdentifiers: [UNUserNotificationCenter.deadmanNotificationIdentifier])
	}
}
