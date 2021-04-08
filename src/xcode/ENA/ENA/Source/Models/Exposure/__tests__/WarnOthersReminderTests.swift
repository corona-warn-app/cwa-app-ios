//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

class WarnOthersReminderTests: XCTestCase {
	
	func testTimeIntervalsAreInitializedCorrectly() throws {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)
		
		XCTAssertEqual(
			warnOthersReminder.notificationOneTimeInterval,
			WarnOthersNotificationsTimeInterval.intervalOne
		)

		XCTAssertEqual(
			warnOthersReminder.notificationTwoTimeInterval,
			WarnOthersNotificationsTimeInterval.intervalTwo
		)
	}

	func testIntervalsAreWrittenToStore() throws {
		let store = MockTestStore()
		let warnOthersReminder = WarnOthersReminder(store: store)

		warnOthersReminder.notificationOneTimeInterval = TimeInterval(42)
		XCTAssertEqual(warnOthersReminder.notificationOneTimeInterval, TimeInterval(42))
		XCTAssertEqual(store.warnOthersNotificationOneTimeInterval, TimeInterval(42))

		warnOthersReminder.notificationTwoTimeInterval = TimeInterval(43)
		XCTAssertEqual(warnOthersReminder.notificationTwoTimeInterval, TimeInterval(43))
		XCTAssertEqual(store.warnOthersNotificationTwoTimeInterval, TimeInterval(43))
	}
	
	func testPCRNotificationsAreScheduledCorrectly() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let warnOthersReminder = WarnOthersReminder(
			store: MockTestStore(),
			userNotificationCenter: mockNotificationCenter
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		warnOthersReminder.scheduleNotifications(for: .pcr)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].content.title,
			AppStrings.WarnOthersNotification.title
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].content.body,
			AppStrings.WarnOthersNotification.description
		)

		XCTAssertEqual(
			(mockNotificationCenter.notificationRequests[0].trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval,
			warnOthersReminder.notificationOneTimeInterval
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].content.title,
			AppStrings.WarnOthersNotification.title
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].content.body,
			AppStrings.WarnOthersNotification.description
		)

		XCTAssertEqual(
			(mockNotificationCenter.notificationRequests[1].trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval,
			warnOthersReminder.notificationTwoTimeInterval
		)
	}

	func testAntigenNotificationsAreScheduledCorrectly() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let warnOthersReminder = WarnOthersReminder(
			store: MockTestStore(),
			userNotificationCenter: mockNotificationCenter
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		warnOthersReminder.scheduleNotifications(for: .antigen)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].content.title,
			AppStrings.WarnOthersNotification.title
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].content.body,
			AppStrings.WarnOthersNotification.description
		)

		XCTAssertEqual(
			(mockNotificationCenter.notificationRequests[0].trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval,
			warnOthersReminder.notificationOneTimeInterval
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].content.title,
			AppStrings.WarnOthersNotification.title
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].content.body,
			AppStrings.WarnOthersNotification.description
		)

		XCTAssertEqual(
			(mockNotificationCenter.notificationRequests[1].trigger as? UNTimeIntervalNotificationTrigger)?.timeInterval,
			warnOthersReminder.notificationTwoTimeInterval
		)
	}

	func testPCRNotificationsAreCancelledCorrectly() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let warnOthersReminder = WarnOthersReminder(
			store: MockTestStore(),
			userNotificationCenter: mockNotificationCenter
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		warnOthersReminder.scheduleNotifications(for: .pcr)
		warnOthersReminder.scheduleNotifications(for: .antigen)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 4)

		warnOthersReminder.cancelNotifications(for: .pcr)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier
		)
	}

	func testAntigenNotificationsAreCancelledCorrectly() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let warnOthersReminder = WarnOthersReminder(
			store: MockTestStore(),
			userNotificationCenter: mockNotificationCenter
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		warnOthersReminder.scheduleNotifications(for: .pcr)
		warnOthersReminder.scheduleNotifications(for: .antigen)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 4)

		warnOthersReminder.cancelNotifications(for: .antigen)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier
		)

		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier
		)
	}

	func testResetCancelsAllNotifications() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let warnOthersReminder = WarnOthersReminder(
			store: MockTestStore(),
			userNotificationCenter: mockNotificationCenter
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		warnOthersReminder.scheduleNotifications(for: .pcr)
		warnOthersReminder.scheduleNotifications(for: .antigen)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 4)

		warnOthersReminder.reset()

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)
	}
	
}
