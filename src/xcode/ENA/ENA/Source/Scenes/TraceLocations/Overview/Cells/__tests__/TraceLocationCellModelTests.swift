////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationCellModelTests: XCTestCase {

	func testGIVEN_CellModelWithPermanentTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt"
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
		XCTAssertNil(cellViewModel.timePublisher.value)
	}

	func testGIVEN_CellModelWithTemporaryOneDayTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(timeIntervalSince1970: 1616074184),
			endDate: Date(timeIntervalSince1970: 1616075184)
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

		XCTAssertNotNil(cellViewModel.date)
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
		XCTAssertNotNil(cellViewModel.timePublisher.value)
	}

	func testGIVEN_CellModelWithTemporaryMultiDayTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(timeIntervalSince1970: 1616074184),
			endDate: Date(timeIntervalSince1970: 1617075184)
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
		XCTAssertNotNil(cellViewModel.timePublisher.value)
	}

	func testGIVEN_CheckInCellModel_WHEN_UpdateCheckinForEvent_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let traceLocation = TraceLocation.mock(
			id: "42".data(using: .utf8) ?? Data(),
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
		let checkin = Checkin.mock(id: 0, traceLocationId: "42".data(using: .utf8) ?? Data(), checkinEndDate: Date(timeIntervalSince1970: 1616074530), checkinCompleted: true)
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

	func testGIVEN_TraceLocationCellModel_THEN_onUpdateGetsCalledOnCheckin() {
		let traceLocationId = "42".data(using: .utf8) ?? Data()

		let traceLocation = TraceLocation.mock(
			id: traceLocationId,
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(),
			endDate: Date(timeIntervalSinceNow: 5)
		)
		let eventStore = MockEventStore()
		let didUpdateExpectation = expectation(description: "didUpdate")

		let cellModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: eventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		eventStore.createCheckin(
			Checkin.mock(traceLocationId: traceLocationId, checkinCompleted: false)
		)

		XCTAssertFalse(cellModel.isButtonHiddenPublisher.value)

		wait(for: [didUpdateExpectation], timeout: .medium)

		XCTAssertTrue(cellModel.isButtonHiddenPublisher.value)
	}

	func testGIVEN_TraceLocationCellModel_THEN_onUpdateGetsCalledOnCheckout() {
		let traceLocationId = "42".data(using: .utf8) ?? Data()

		let traceLocation = TraceLocation.mock(
			id: traceLocationId,
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(),
			endDate: Date(timeIntervalSinceNow: 5)
		)

		let eventStore = MockEventStore()
		let storeResult = eventStore.createCheckin(
			Checkin.mock(traceLocationId: traceLocationId, checkinCompleted: false)
		)

		let didUpdateExpectation = expectation(description: "didUpdate")

		let cellModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: eventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		XCTAssertTrue(cellModel.isButtonHiddenPublisher.value)

		guard case .success(let id) = storeResult else {
			XCTFail("could not get id from store")
			return
		}

		eventStore.deleteCheckin(id: id)

		wait(for: [didUpdateExpectation], timeout: .medium)

		XCTAssertFalse(cellModel.isButtonHiddenPublisher.value)
	}

	func testGIVEN_TraceLocationCellModel_THEN_onUpdateDoesNotGetCalledOnInit() {
		let traceLocationId = "42".data(using: .utf8) ?? Data()

		let traceLocation = TraceLocation.mock(
			id: traceLocationId,
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(),
			endDate: Date(timeIntervalSinceNow: 5)
		)
		let eventStore = MockEventStore()

		let didUpdateExpectation = expectation(description: "didUpdate")
		didUpdateExpectation.isInverted = true

		let cellModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: eventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		XCTAssertFalse(cellModel.isButtonHiddenPublisher.value)

		wait(for: [didUpdateExpectation], timeout: .medium)
	}

	func testGIVEN_TraceLocationCellModel_THEN_onUpdateDoesNotGetCalledOnUnrelatedUpdates() {
		let traceLocation = TraceLocation.mock(
			id: "42".data(using: .utf8) ?? Data(),
			description: "Sportstudio",
			address: "Musterstraße 1a, 01234 Musterstadt",
			startDate: Date(),
			endDate: Date(timeIntervalSinceNow: 5)
		)
		let eventStore = MockEventStore()

		let didUpdateExpectation = expectation(description: "didUpdate")
		didUpdateExpectation.isInverted = true

		let cellModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: eventStore,
			onUpdate: { didUpdateExpectation.fulfill() }
		)

		eventStore.createCheckin(
			Checkin.mock(
				traceLocationId: "43".data(using: .utf8) ?? Data(),
				checkinCompleted: false
			)
		)

		XCTAssertFalse(cellModel.isButtonHiddenPublisher.value)

		wait(for: [didUpdateExpectation], timeout: .medium)

		XCTAssertFalse(cellModel.isButtonHiddenPublisher.value)
	}

}
