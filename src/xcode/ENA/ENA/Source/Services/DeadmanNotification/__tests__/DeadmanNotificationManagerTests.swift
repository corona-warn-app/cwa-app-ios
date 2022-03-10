//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class DeadmanNotificationManagerTests: CWATestCase {

	func testSchedulingDeadmanNotification() {
		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			coronaTestService: MockCoronaTestService(),
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

	func testDeadmanNotificationReschedulingOnReset() {
		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: MockCoronaTestService(),
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.resetDeadmanNotification()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	func testDeadmanNotificationIsNotScheduledTwice() {
		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: MockCoronaTestService(),
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	// MARK: - Private

	private var deadmanNotificationRequest: UNNotificationRequest {
		let content = UNMutableNotificationContent()
		content.title = AppStrings.Common.deadmanAlertTitle
		content.body = AppStrings.Common.deadmanAlertBody
		content.sound = .default

		let trigger = UNTimeIntervalNotificationTrigger(
			timeInterval: 36 * 60 * 60,
			repeats: false
		)

		return UNNotificationRequest(
			identifier: DeadmanNotificationManager.deadmanNotificationIdentifier,
			content: content,
			trigger: trigger
		)
	}

}
