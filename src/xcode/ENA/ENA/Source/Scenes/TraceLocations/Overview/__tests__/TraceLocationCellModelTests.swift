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
			startDate: Date(timeIntervalSince1970: 1616074184),
			endDate: Date(timeIntervalSince1970: 1616074530)
		)
		let cellViewModel = TraceLocationCellModel(
			traceLocation: traceLocation,
			eventProvider: MockEventStore(),
			onUpdate: {}
		)

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
