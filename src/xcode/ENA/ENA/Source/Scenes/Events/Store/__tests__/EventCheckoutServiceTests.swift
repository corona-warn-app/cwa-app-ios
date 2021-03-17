////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class EventCheckoutServiceTests: XCTestCase {

	var subscriptions = Set<AnyCancellable>()

	func test_When_Checkout_Then_CheckinWasUpdated() {
		let mockEventStore = MockEventStore()
		let checkin = makeDummyCheckin(id: -1)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockNotificationCenter = MockUserNotificationCenter()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockNotificationCenter
		)
		let checkinWithId = makeDummyCheckin(id: checkinId)
		eventCheckoutService.checkout(checkin: checkinWithId, showNotification: false)

		let sinkExpectation = expectation(description: "Sink should be called.")
		mockEventStore.checkinsPublisher.sink { checkins in
			XCTAssertEqual(checkins.count, 1)
			XCTAssertNotNil(checkins[0].checkinEndDate)
			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)

		waitForExpectations(timeout: .medium)
	}

	func test_When_Checkout_Then_ContactDiaryCreated() {
		let mockEventStore = MockEventStore()
		let checkin = makeDummyCheckin(id: -1)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockDiaryStore = MockDiaryStore()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)
		let checkinWithId = makeDummyCheckin(
			id: checkinId,
			traceLocationGUID: "someGUID"
		)
		eventCheckoutService.checkout(checkin: checkinWithId, showNotification: false)

		let sinkExpectation = expectation(description: "Sink should be called.")
		mockDiaryStore.diaryDaysPublisher.sink { diaryDays in
			let locations: [DiaryLocation] = diaryDays[0].entries.compactMap {
				if case let .location(location) = $0 {
					return location
				} else {
					return nil
				}
			}
			let checkinLocationExists = locations.contains {
				$0.traceLocationGUID == "someGUID"
			}
			XCTAssertTrue(checkinLocationExists)

			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .medium)
	}

	func test_When_CheckoutWithNotification_Then_NotificationIsShown() {
		let mockEventStore = MockEventStore()
		let checkin = makeDummyCheckin(id: -1)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockNotificationCenter = MockUserNotificationCenter()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockNotificationCenter
		)
		let checkinWithId = makeDummyCheckin(id: checkinId)
		eventCheckoutService.checkout(checkin: checkinWithId, showNotification: true)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 1)
	}

	func test_When_checkoutOverdueCheckins_Then_OverdueCheckinsAreUpdated() {
		let mockEventStore = MockEventStore()
		let overdueCheckin = makeDummyCheckin(id: -1, targetCheckinEndDate: Date.distantPast)
		mockEventStore.createCheckin(overdueCheckin)
		mockEventStore.createCheckin(overdueCheckin)

		let currentCheckin = makeDummyCheckin(id: -1, targetCheckinEndDate: Date.distantFuture)
		mockEventStore.createCheckin(currentCheckin)

		let mockNotificationCenter = MockUserNotificationCenter()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockNotificationCenter
		)
		eventCheckoutService.checkoutOverdueCheckins()

		let sinkExpectation = expectation(description: "Sink should be called.")
		mockEventStore.checkinsPublisher.sink { checkins in
			XCTAssertEqual(checkins.count, 3)

			let checkedOutCount = checkins.filter { $0.checkinEndDate != nil }.count
			XCTAssertEqual(checkedOutCount, 2)

			let notCheckedOutCount = checkins.filter { $0.checkinEndDate == nil }.count
			XCTAssertEqual(notCheckedOutCount, 1)

			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)

		waitForExpectations(timeout: .medium)
	}

	func makeDummyCheckin(
		id: Int,
		targetCheckinEndDate: Date = Date(),
		traceLocationGUID: String = "0"
	) -> Checkin {
		Checkin(
			id: id,
			traceLocationGUID: traceLocationGUID,
			traceLocationVersion: 0,
			traceLocationType: .type1,
			traceLocationDescription: "",
			traceLocationAddress: "",
			traceLocationStartDate: Date(),
			traceLocationEndDate: Date(),
			traceLocationDefaultCheckInLengthInMinutes: 0,
			traceLocationSignature: "",
			checkinStartDate: Date(),
			checkinEndDate: nil,
			targetCheckinEndDate: targetCheckinEndDate,
			createJournalEntry: true
		)
	}
}
