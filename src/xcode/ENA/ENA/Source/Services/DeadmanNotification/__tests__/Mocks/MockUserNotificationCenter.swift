//
// 🦠 Corona-Warn-App
//

import UserNotifications
@testable import ENA

class MockUserNotificationCenter: UserNotificationCenter {

	// MARK: - Protocol UserNotificationCenter

	func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
		completionHandler(notificationRequests)
	}

	func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
		notificationRequests.append(request)
		onAdding?(request)
	}

	func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
		notificationRequests.removeAll(where: { identifiers.contains($0.identifier) })
	}

	// MARK: - Internal

	var notificationRequests = [UNNotificationRequest]()
	var onAdding: ((UNNotificationRequest) -> Void)?

}
