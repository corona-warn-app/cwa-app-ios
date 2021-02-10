//
// 🦠 Corona-Warn-App
//

import UserNotifications
@testable import ENA

class MockUserNotificationCenter: UserNotificationCenter {

	var notificationRequests = [UNNotificationRequest]()

	func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
		completionHandler(notificationRequests)
	}

	func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
		notificationRequests.append(request)
	}

	func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
		notificationRequests.removeAll(where: { identifiers.contains($0.identifier) })
	}

}
