//
// 🦠 Corona-Warn-App
//

import UserNotifications

extension UNUserNotificationCenter {
	
	// MARK: - Public
	
	/// Schedule a local notification to fire 2 hours if users has not warn to others. Scedule one more notification after 4 hours if still user has not share the keys.
	func scheduleWarnOthersNotifications(timeIntervalOne: TimeInterval, timeIntervalTwo: TimeInterval) {
		presentNotification(identifier: ActionableNotificationIdentifier.warnOthersReminder1.identifier, in: timeIntervalOne)
		presentNotification(identifier: ActionableNotificationIdentifier.warnOthersReminder2.identifier, in: timeIntervalTwo)
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
