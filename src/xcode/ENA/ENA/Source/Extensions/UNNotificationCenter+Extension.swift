//
// 🦠 Corona-Warn-App
//

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
		in timeInterval: TimeInterval = 1,
		info: [AnyHashable: Any] = [:]
	) {
		let content = UNMutableNotificationContent()

		content.title = title
		content.body = body
		content.sound = UNNotificationSound.default
		content.badge = 1
		content.categoryIdentifier = identifier
		content.userInfo = info
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		add(request) { error in
			if let error = error {
				Log.error(error.localizedDescription, log: .api)
			}
		}
	}

}
