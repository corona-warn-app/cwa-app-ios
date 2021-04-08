//
// 🦠 Corona-Warn-App
//

import UserNotifications

extension UNUserNotificationCenter {
	
	// MARK: - Internal
	
	/// Schedule a local notification to fire 2 hours if users has not warn to others. Schedule one more notification after 4 hours if still user has not share the keys.
	func scheduleWarnOthersNotifications(coronaTestType: CoronaTestType, timeIntervalOne: TimeInterval, timeIntervalTwo: TimeInterval) {
		switch coronaTestType {
		case .pcr:
			presentNotification(identifier: ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier, in: timeIntervalOne)
			presentNotification(identifier: ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier, in: timeIntervalTwo)
		case .antigen:
			presentNotification(identifier: ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier, in: timeIntervalOne)
			presentNotification(identifier: ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier, in: timeIntervalTwo)
		}
	}
	
	/// Cancels the Warn Others Notification
	func cancelWarnOthersNotification(coronaTestType: CoronaTestType) {
		switch coronaTestType {
		case .pcr:
			removePendingNotificationRequests(withIdentifiers: [
				ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier,
				ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier
			])
		case .antigen:
			removePendingNotificationRequests(withIdentifiers: [
				ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier,
				ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier
			])
		}

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
