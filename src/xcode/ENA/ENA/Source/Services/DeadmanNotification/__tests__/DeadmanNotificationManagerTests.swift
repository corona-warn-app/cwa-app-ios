//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class DeadmanNotificationManagerTests: CWATestCase {

	func testSchedulingDeadmanNotification() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
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
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.resetDeadmanNotification()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	func testDeadmanNotificationIsNotScheduledTwice() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			userNotificationCenter: notificationCenter
		)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
	}

	func testDeadmanNotificationIsNotScheduledIfPositiveTestResultWasShown() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(positiveTestResultWasShown: true)

		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			userNotificationCenter: notificationCenter
		)

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotRescheduledIfPositiveTestResultWasShown() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(positiveTestResultWasShown: true)

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			userNotificationCenter: notificationCenter
		)

		XCTAssertFalse(notificationCenter.notificationRequests.isEmpty)

		manager.resetDeadmanNotification()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotScheduledIfKeysWereSubmitted() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(keysSubmitted: true)

		let notificationCenter = MockUserNotificationCenter()

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			userNotificationCenter: notificationCenter
		)

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)

		manager.scheduleDeadmanNotificationIfNeeded()

		XCTAssertTrue(notificationCenter.notificationRequests.isEmpty)
	}

	func testDeadmanNotificationIsNotRescheduledIfKeysWereSubmitted() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		store.pcrTest = PCRTest.mock(keysSubmitted: true)

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [deadmanNotificationRequest]

		let manager = DeadmanNotificationManager(
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfiguration,
					cclService: FakeCCLService(),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
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
