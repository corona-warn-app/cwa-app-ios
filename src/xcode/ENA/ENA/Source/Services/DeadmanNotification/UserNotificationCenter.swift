//
// 🦠 Corona-Warn-App
//

import UserNotifications

protocol UserNotificationCenter {
	func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
	func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
	func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenter { }
