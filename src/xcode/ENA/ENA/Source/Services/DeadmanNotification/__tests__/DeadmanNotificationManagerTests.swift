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

	func testDeadmanNotificationReschedulingOnReset() {
		let store = MockTestStore()

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.resetDeadmanNotification()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	func testDeadmanNotificationIsNotScheduledTwice() {
		let store = MockTestStore()

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	func testDeadmanNotificationIsNotScheduledIfPositiveTestResultWasShown() {
		let store = MockTestStore()
		store.positiveTestResultWasShown = true

		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotRescheduledIfPositiveTestResultWasShown() {
		let store = MockTestStore()
		store.positiveTestResultWasShown = true

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertFalse(notificationCenter.notificationRequests.isEmpty)

		manager.resetDeadmanNotification()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotScheduledIfKeysWereSubmitted() {
		let store = MockTestStore()
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = 12345678

		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotRescheduledIfKeysWereSubmitted() {
		let store = MockTestStore()
		store.lastSuccessfulSubmitDiagnosisKeyTimestamp = 12345678

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			store: store,
			userNotificationCenter: notificationCenter
		)

		XCTAssertFalse(notificationCenter.notificationRequests.isEmpty)

		manager.resetDeadmanNotification()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
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
