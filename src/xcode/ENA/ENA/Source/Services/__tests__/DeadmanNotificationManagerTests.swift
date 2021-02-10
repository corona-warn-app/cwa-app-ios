//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DeadmanNotificationManagerTests: XCTestCase {

	func testSchedulingDeadmanNotification() {
		let store = MockTestStore()
		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)

		manager.scheduleDeadmanNotificationIfNeeded()

		guard let notificationRequest = notificationCenter.notificationRequests.first else {
			XCTFail("Deadman notification should have been scheduled")
			return
		}

		XCTAssertEqual(notificationRequest.identifier, DeadmanNotificationManager.deadmanNotificationIdentifier)

		XCTAssertEqual(notificationRequest.content.title, AppStrings.Common.deadmanAlertTitle)
		XCTAssertEqual(notificationRequest.content.body, AppStrings.Common.deadmanAlertBody)
		XCTAssertEqual(notificationRequest.content.sound, .default)

		guard let notificationTrigger = notificationRequest.trigger as? UNTimeIntervalNotificationTrigger else {
			XCTFail("Deadman notification should have a trigger of type UNTimeIntervalNotificationTrigger")
			return
		}

		XCTAssertEqual(notificationTrigger.timeInterval, 36 * 60 * 60)
		XCTAssertFalse(notificationTrigger.repeats)
	}

}
