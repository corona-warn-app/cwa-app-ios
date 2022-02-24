//
// 🦠 Corona-Warn-App
//

import UserNotifications

public enum ActionableNotificationIdentifier: String {
	case testResult = "test-result"
	case testResultType = "test-result-type"
	case riskDetection = "risk-detection"
	case deviceTimeCheck = "device-time-check"
	case pcrWarnOthersReminder1 = "pcr-warn-others-reminder-1"
	case pcrWarnOthersReminder2 = "pcr-warn-others-reminder-2"
	case antigenWarnOthersReminder1 = "antigen-warn-others-reminder-1"
	case antigenWarnOthersReminder2 = "antigen-warn-others-reminder-2"

	var identifier: String {
		let bundleIdentifier = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"
		return "\(bundleIdentifier).\(rawValue)"
	}
}

public enum LocalNotificationIdentifier: String {
	case checkout = "EventCheckoutNotification"
	case certificateExpiringSoon = "HealthCertificateNotificationExpireSoon"
	case certificateExpired = "HealthCertificateNotificationExpired"
	case certificateInvalid = "HealthCertificateNotificationInvalid"
	case certificateBlocked = "HealthCertificateNotificationBlocked"
	case boosterVaccination = "BoosterVaccinationNotification"
	case certificateReissuance = "CertificateReissuanceNotification"
}

extension UserNotificationCenter {

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
		if #available(iOS 15.0, *) {
			content.interruptionLevel = .timeSensitive
		}
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

		add(request) { error in
			if let error = error {
				Log.error(error.localizedDescription, log: .api)
			}
		}
	}

}
