//
// 🦠 Corona-Warn-App
//

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
				Log.error(error.localizedDescription, log: .api)
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
