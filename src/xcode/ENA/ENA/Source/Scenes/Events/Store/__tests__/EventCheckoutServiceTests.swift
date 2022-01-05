////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class EventCheckoutServiceTests: CWATestCase {

	var subscriptions = Set<AnyCancellable>()

	// EventCheckoutService needs to be in memory. The magic is happening there.
	// The EventCheckoutService creates journal entries internally if the event store changes.
	var eventCheckoutService: EventCheckoutService?

	func test_When_Checkout_Then_ContactDiaryLocationCreated() throws {
		let mockEventStore = MockEventStore()

		let today = Date()
		guard let tomorrow = Calendar.utcCalendar.date(byAdding: .day, value: 1, to: today) else {
			XCTFail("Could not create date.")
			return
		}

		let checkin = Checkin.mock(
			id: -1,
			createJournalEntry: true
		)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockDiaryStore = MockDiaryStore()

		eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)

		// Updating checkin with 'checkinCompleted == true' will trigger a checkout handling in the EventCheckoutService.
		let checkinWithData = Checkin.mock(
			id: checkinId,
			traceLocationId: "someGUID".data(using: .utf8) ?? Data(),
			traceLocationDescription: "Some Description",
			traceLocationAddress: "Some Address",
			traceLocationStartDate: today,
			traceLocationEndDate: tomorrow,
			createJournalEntry: true
		)
		let completedCheckin = checkinWithData.completedCheckin(checkinEndDate: Date())
		mockEventStore.updateCheckin(completedCheckin)

		let _checkinLocation = mockDiaryStore.locations.first(where: {
			$0.traceLocationId == "someGUID".data(using: .utf8)
		})
		let checkinLocation = try XCTUnwrap(_checkinLocation)

		XCTAssertEqual(checkinLocation.name, "Some Description, Some Address")
	}

	func test_When_Checkout_Then_ContactDiaryLocationVisitsCreated() {
		let mockEventStore = MockEventStore()
		let checkin = Checkin.mock(id: -1, createJournalEntry: true)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockDiaryStore = MockDiaryStore()

		eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)

		// Updating checkin with 'checkinCompleted == true' will trigger a checkout handling in the EventCheckoutService.
		let completedCheckin = Checkin.mock(
			id: checkinId,
			traceLocationId: "someGUID".data(using: .utf8) ?? Data(),
			checkinCompleted: true,
			createJournalEntry: true
		)
		mockEventStore.updateCheckin(completedCheckin)

		XCTAssertEqual(mockDiaryStore.locations.count, 1)
		XCTAssertEqual(mockDiaryStore.locationVisits.count, 1)
	}

	func test_Given_FirstCheckout_When_SecondCheckoutOfSameLocationAndSameDate_Then_OnlyOneLocationVisitIsCreated() {

		// Given

		let mockEventStore = MockEventStore()
		let checkin = Checkin.mock(id: -1, createJournalEntry: true)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}
		let completedCheckin = Checkin.mock(
			id: checkinId,
			traceLocationId: "someGUID".data(using: .utf8) ?? Data(),
			checkinCompleted: true,
			createJournalEntry: true
		)
		mockEventStore.updateCheckin(completedCheckin)

		// When
		let checkin2 = Checkin.mock(
			id: -1,
			createJournalEntry: true
		)
		let createCheckinResult2 = mockEventStore.createCheckin(checkin2)
		guard case let .success(checkinId2) = createCheckinResult2 else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockDiaryStore = MockDiaryStore()

		eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)

		// The sink should not be called after adding a second checkout with the same location and the same day.
		// Because in this case no Location and no LocationVisit is created, and the publisher doesn't change.
		let sinkExpectation = expectation(description: "Sink should not be called.")
		sinkExpectation.isInverted = true

		mockDiaryStore.diaryDaysPublisher.dropFirst().sink { _ in
			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		// Updating checkin with 'checkinCompleted == true' will trigger a checkout handling in the EventCheckoutService.
		let completedCheckin2 = Checkin.mock(
			id: checkinId2,
			traceLocationId: "someGUID".data(using: .utf8) ?? Data(),
			checkinCompleted: true,
			createJournalEntry: true
		)
		mockEventStore.updateCheckin(completedCheckin2)

		waitForExpectations(timeout: .short)

		// After checkout of 2 checkins on the same day and same location, only 1 LocationVisit should exist.
		XCTAssertEqual(mockDiaryStore.locationVisits.count, 1)
		XCTAssertEqual(mockDiaryStore.locations.count, 1)
	}

	func test_When_checkoutOverdueCheckins_Then_OnlyOverdueCheckinsAreCompleted() {
		let mockEventStore = MockEventStore()
		let overdueCheckin = Checkin.mock(
			id: -1,
			checkinEndDate: Date.distantPast,
			createJournalEntry: true
		)
		mockEventStore.createCheckin(overdueCheckin)
		mockEventStore.createCheckin(overdueCheckin)

		let currentCheckin = Checkin.mock(
			id: -1,
			checkinEndDate: Date.distantFuture,
			createJournalEntry: true
		)
		mockEventStore.createCheckin(currentCheckin)

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: MockUserNotificationCenter()
		)
		eventCheckoutService.checkoutOverdueCheckins()

		let sinkExpectation = expectation(description: "Sink should be called.")
		mockEventStore.checkinsPublisher.sink { checkins in
			XCTAssertEqual(checkins.count, 3)

			let checkedOutCount = checkins.filter { $0.checkinCompleted }.count
			XCTAssertEqual(checkedOutCount, 2)

			let notCheckedOutCount = checkins.filter { !$0.checkinCompleted }.count
			XCTAssertEqual(notCheckedOutCount, 1)

			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		waitForExpectations(timeout: .short)
	}

	func test_When_CheckoutCheckinOfMoreThenOneDay_Then_TwoLocationVisitsAreCreated() {
		guard
			let todayDate = utcFormatter.date(from: "2021-03-06T09:30:00+01:00"),
			let traceLocationStartDate = utcFormatter.date(from: "2021-03-03T08:00:00+01:00"),
			  let traceLocationEndDate = utcFormatter.date(from: "2021-03-06T22:00:00+01:00"),
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-05T09:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let twoDayCheckin = Checkin.mock(
			id: -1,
			traceLocationId: "id".data(using: .utf8) ?? Data(),
			traceLocationDescription: "Some Description",
			traceLocationAddress: "Some Address",
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			createJournalEntry: true
		)

		let mockEventStore = MockEventStore()
		mockEventStore.createCheckin(twoDayCheckin)

		let dateProvider = DateProvider(date: todayDate)

		let mockDiaryStore = MockDiaryStore(dateProvider: dateProvider)

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)

		let sinkExpectation = expectation(description: "Sink should be called.")
		sinkExpectation.expectedFulfillmentCount = 2
		mockEventStore.checkinsPublisher.dropFirst().sink { _ in
			sinkExpectation.fulfill()
		}.store(in: &subscriptions)

		eventCheckoutService.checkoutOverdueCheckins()

		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockDiaryStore.locations.count, 1)
		XCTAssertEqual(mockDiaryStore.locationVisits.count, 2)
		XCTAssertEqual(mockDiaryStore.locationVisits[0].date, "2021-03-04")
		XCTAssertEqual(mockDiaryStore.locationVisits[1].date, "2021-03-05")
	}

	func test_When_Checkout_Then_NotificationIsRequested() {
		let mockEventStore = MockEventStore()
		let checkin = Checkin.mock(id: -1)
		let createCheckinResult = mockEventStore.createCheckin(checkin)
		guard case let .success(checkinId) = createCheckinResult else {
			XCTFail("Could not create checkin.")
			return
		}

		let mockNotificationCenter = MockUserNotificationCenter()

		eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockNotificationCenter
		)
		_ = Checkin.mock(id: checkinId)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 1)
	}

	func test_When_CheckoutOverdueCheckins_Then_NotificationRequestsAreChanged() {
		let mockEventStore = MockEventStore()
		let overdueCheckin = Checkin.mock(id: -1, checkinEndDate: Date.distantPast)
		mockEventStore.createCheckin(overdueCheckin)
		mockEventStore.createCheckin(overdueCheckin)

		let currentCheckin = Checkin.mock(id: -1, checkinEndDate: Date.distantFuture)
		mockEventStore.createCheckin(currentCheckin)

		let mockUserNotificationCenter = MockUserNotificationCenter()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockUserNotificationCenter
		)

		// Before calling checkoutOverdueCheckins there should be 3 notification requests pending.
		// After calling checkoutOverdueCheckins the overdue checkins should be completed and the notification request is removed. Resulting in 1 notification request left for the not overdue checkin.

		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 3)
		eventCheckoutService.checkoutOverdueCheckins()
		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 1)
	}

	func test_When_CheckoutCheckinOverAPI_Then_NotificationRequestsAreChanged() {
		let mockEventStore = MockEventStore()
		let currentCheckin = Checkin.mock(id: -1, checkinEndDate: Date.distantFuture)
		mockEventStore.createCheckin(currentCheckin)

		let result = mockEventStore.createCheckin(currentCheckin)
		guard case let .success(checkinId) = result else {
			XCTFail("Failure not expected.")
			return
		}

		let checkinWithId = Checkin.mock(id: checkinId)

		let mockUserNotificationCenter = MockUserNotificationCenter()

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockUserNotificationCenter
		)

		// Before calling checkoutOverdueCheckins there should be 2 notification requests pending, because 2 checkins where created.
		// After calling checkout for 1 checkin, only 1 notification requests should be pending.

		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 2)
		eventCheckoutService.checkout(checkin: checkinWithId, manually: false)
		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 1)
	}

	func test_When_SetCheckinToCompleted_Then_NotificationRequestsAreChanged() {
		let mockEventStore = MockEventStore()
		let currentCheckin = Checkin.mock(id: -1, checkinEndDate: Date.distantFuture)
		mockEventStore.createCheckin(currentCheckin)

		let result = mockEventStore.createCheckin(currentCheckin)
		guard case let .success(checkinId) = result else {
			XCTFail("Failure not expected.")
			return
		}

		let completedCheckin = Checkin.mock(id: checkinId, checkinCompleted: true)

		let mockUserNotificationCenter = MockUserNotificationCenter()

		eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockUserNotificationCenter
		)

		// Before calling checkoutOverdueCheckins there should be 2 notification requests pending, because 2 checkins where created.
		// After calling updating checkout to 'checkinCompleted == true' for 1 checkin, only 1 notification requests should be pending.

		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 2)

		// Updating checkin with 'checkinCompleted == true' will trigger a checkout handling in the EventCheckoutService.
		mockEventStore.updateCheckin(completedCheckin)
		
		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 1)
	}

	func test_When_CheckoutOverdueCheckins_Then_OnlyEventCheckoutServiceNotificationsAreAffected() {
		let mockEventStore = MockEventStore()
		let overdueCheckin = Checkin.mock(id: -1, checkinEndDate: Date.distantPast)
		mockEventStore.createCheckin(overdueCheckin)

		let mockUserNotificationCenter = MockUserNotificationCenter()
		let request = UNNotificationRequest(identifier: "SomeOther", content: UNNotificationContent(), trigger: nil)
		mockUserNotificationCenter.add(request, withCompletionHandler: nil)

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: MockDiaryStore(),
			userNotificationCenter: mockUserNotificationCenter
		)

		// Before calling checkoutOverdueCheckins there should be 2 notification requests pending. 1 from the EventCheckoutService and 1 other.
		// After calling checkoutOverdueCheckins the EventCheckoutService notification request should be removed. The notification request from NOT EventCheckoutService should still be pending.

		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 2)
		eventCheckoutService.checkoutOverdueCheckins()
		XCTAssertEqual(mockUserNotificationCenter.notificationRequests.count, 1)
	}

	var utcFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()

	private lazy var shortDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()

	private lazy var dateIntervalFormatter: DateIntervalFormatter = {
		let formatter = DateIntervalFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}()
}
