////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationCellModelTests: XCTestCase {

	func testGIVEN_CheckInCellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(timeIntervalSince1970: 1616074184)
		)
		let cellViewModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: MockEventStore(),
			onUpdate: {}
		)

		// THEN
		XCTAssertTrue(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertFalse(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertNil(cellViewModel.date)
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
	}

	func testGIVEN_CheckInCellModel_WHEN_UpdateCheckinForEvent_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			guid: "42",
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(timeIntervalSince1970: 1616074184)
		)
		let mockEventStore = MockEventStore()
		let didUpdateExpectation = expectation(description: "didUpdate")
		didUpdateExpectation.isInverted = true

		let cellViewModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: mockEventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		// WHEN
		let checkin = Checkin.mock(id: 0, traceLocationGUID: "42", checkinEndDate: Date(timeIntervalSince1970: 1616074530))
		mockEventStore.checkinsPublisher.send([checkin])
		wait(for: [didUpdateExpectation], timeout: .medium)

		// THEN
		XCTAssertTrue(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertFalse(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertNil(cellViewModel.date)
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
	}

	func testGIVEN_CheckInCellModel_WHEN_UpdateTimerIsSetup_THEN_onUpdateGetsCalled() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			guid: "42",
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(),
			endDate: Date(timeIntervalSinceNow: 5)
		)
		let mockEventStore = MockEventStore()
		let didUpdateExpectation = expectation(description: "didUpdate")

		let cellViewModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: mockEventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		// WHEN
		wait(for: [didUpdateExpectation], timeout: .medium)

		// THEN
		XCTAssertFalse(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertFalse(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.date, "18.03.21")
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
	}

}
