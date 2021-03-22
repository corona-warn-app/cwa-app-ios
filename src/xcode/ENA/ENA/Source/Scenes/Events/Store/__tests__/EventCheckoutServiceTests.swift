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

		guard let targetCheckinEndDate = utcFormatter.date(from: "2021-03-06T22:00:00+01:00") else {
			XCTFail("Could not create date.")
			return
		}

		let checkinWithId = makeDummyCheckin(
			id: checkinId,
			targetCheckinEndDate: targetCheckinEndDate
		)
		eventCheckoutService.checkout(checkin: checkinWithId, showNotification: false)

		let sinkExpectation = expectation(description: "Sink should be called.")
		mockEventStore.checkinsPublisher.sink { checkins in
			XCTAssertEqual(checkins.count, 1)
			XCTAssertEqual(checkins[0].checkinEndDate, targetCheckinEndDate)
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

	func test_When_checkoutCheckinOfMoreThenOneDay_Then_TwoLocationVisitsAreCreated() {

		guard
			let todayDate = utcFormatter.date(from: "2021-03-06T09:30:00+01:00"),
			let traceLocationStartDate = utcFormatter.date(from: "2021-03-03T08:00:00+01:00"),
			  let traceLocationEndDate = utcFormatter.date(from: "2021-03-06T22:00:00+01:00"),
			let checkinStartDate = utcFormatter.date(from: "2021-03-04T09:30:00+01:00"),
			  let checkinEndDate = utcFormatter.date(from: "2021-03-05T09:30:00+01:00") else {
			XCTFail("Could not create dates.")
			return
		}

		let twoDayCheckin = makeDummyCheckin(
			id: -1,
			checkinStartDate: checkinStartDate,
			targetCheckinEndDate: checkinEndDate,
			traceLocationGUID: "guid",
			traceLocationDescription: "Some Description",
			traceLocationAddress: "Some Address",
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate
		)

		let mockEventStore = MockEventStore()
		mockEventStore.createCheckin(twoDayCheckin)

		var dateProvider = DateProvider()
		dateProvider.today = todayDate

		let mockDiaryStore = MockDiaryStore(dateProvider: dateProvider)

		let eventCheckoutService = EventCheckoutService(
			eventStore: mockEventStore,
			contactDiaryStore: mockDiaryStore,
			userNotificationCenter: MockUserNotificationCenter()
		)
		eventCheckoutService.checkoutOverdueCheckins()

		let diaryDays = mockDiaryStore.diaryDaysPublisher.value.filter {
			$0.dateString == "2021-03-04" ||
			$0.dateString == "2021-03-05"
		}

		XCTAssertEqual(diaryDays.count, 2)

		XCTAssertEqual(diaryDays[0].selectedEntries.count, 1)
		XCTAssertEqual(diaryDays[1].selectedEntries.count, 1)

		let dayEntry0 = diaryDays[0].selectedEntries[0]
		let dayEntry1 = diaryDays[1].selectedEntries[0]

		guard case .location = dayEntry0,
			  case .location = dayEntry1 else {
			XCTFail("Entries should be location visits.")
			return
		}

		let formattedStartDate = shortDateFormatter.string(from: traceLocationStartDate)
		let formattedEndDate = shortDateFormatter.string(from: traceLocationEndDate)
		XCTAssertEqual(dayEntry0.name, "Some Description, Some Address, \(formattedStartDate), \(formattedEndDate)")
	}

	func makeDummyCheckin(
		id: Int,
		checkinStartDate: Date = Date(),
		checkinEndDate: Date? = nil,
		targetCheckinEndDate: Date = Date(),
		traceLocationGUID: String = "0",
		traceLocationDescription: String = "",
		traceLocationAddress: String = "",
		traceLocationStartDate: Date = Date(),
		traceLocationEndDate: Date = Date()
	) -> Checkin {
		Checkin(
			id: id,
			traceLocationGUID: traceLocationGUID,
			traceLocationVersion: 0,
			traceLocationType: .type1,
			traceLocationDescription: traceLocationDescription,
			traceLocationAddress: traceLocationAddress,
			traceLocationStartDate: traceLocationStartDate,
			traceLocationEndDate: traceLocationEndDate,
			traceLocationDefaultCheckInLengthInMinutes: 0,
			traceLocationSignature: "",
			checkinStartDate: checkinStartDate,
			checkinEndDate: checkinEndDate,
			targetCheckinEndDate: targetCheckinEndDate,
			createJournalEntry: true
		)
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
}
