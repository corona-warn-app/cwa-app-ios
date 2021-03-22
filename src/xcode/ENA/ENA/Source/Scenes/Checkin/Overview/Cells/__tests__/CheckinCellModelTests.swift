////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinCellModelTests: XCTestCase {

	func testGIVEN_CheckInCellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let checkin = Checkin.mock(
			id: 0,
			traceLocationDescription: "Sportstudio",
			traceLocationAddress: "Musterstraße 1a, 01234 Musterstadt",
			checkinStartDate: Date(timeIntervalSince1970: 1616074184)
		)
		let cellViewModel = CheckinCellModel(
			checkin: checkin,
			eventProvider: MockEventStore(),
			onUpdate: {}
		)

		// THEN
		XCTAssertEqual(cellViewModel.checkin, checkin)
		XCTAssertTrue(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertFalse(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveIconHidden)
		XCTAssertFalse(cellViewModel.isDurationStackViewHidden)
		XCTAssertFalse(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.date, "18.03.21")
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
	}

	func testGIVEN_CheckInCellModel_WHEN_UpdateWithChecking_THEN_NewCheckInIsSet() {
		// GIVEN
		let checkin = Checkin.mock(
			id: 0,
			traceLocationDescription: "Sportstudio",
			traceLocationAddress: "Musterstraße 1a, 01234 Musterstadt",
			checkinStartDate: Date(timeIntervalSince1970: 1616074184)
		)

		let cellViewModel = CheckinCellModel(
			checkin: checkin,
			eventProvider: MockEventStore(),
			onUpdate: {}
		)

		// WHEN

		let updatedCheckin = Checkin.mock(
			id: 0,
			traceLocationDescription: "Sportstudio",
			traceLocationAddress: "Musterstraße 1a, 01234 Musterstadt",
			checkinStartDate: Date(timeIntervalSince1970: 1616074184),
			checkinEndDate: Date(timeIntervalSince1970: 1616074530),
			checkinCompleted: true
		)
		cellViewModel.update(with: updatedCheckin)

		// THEN
		XCTAssertEqual(cellViewModel.checkin, updatedCheckin)
		XCTAssertFalse(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveIconHidden)
		XCTAssertFalse(cellViewModel.isDurationStackViewHidden)
		XCTAssertTrue(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.date, "18.03.21")
		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
	}

}
