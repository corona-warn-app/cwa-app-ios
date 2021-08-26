////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnBehalfTraceLocationCellModelTests: CWATestCase {

	func testGIVEN_CellModelWithPermanentTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = OnBehalfTraceLocationCellModel(
			traceLocation: .mock(
				description: "Sportstudio",
				address: "Musterstraße 1a, 01234 Musterstadt"
			)
		)

		// THEN
		XCTAssertFalse(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertTrue(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
		XCTAssertNil(cellViewModel.timePublisher.value)
	}

	func testGIVEN_CellModelWithTemporaryOneDayTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = OnBehalfTraceLocationCellModel(
			traceLocation: .mock(
				description: "Sportstudio",
				address: "Musterstraße 1a, 01234 Musterstadt",
				startDate: Date(timeIntervalSince1970: 1616074184),
				endDate: Date(timeIntervalSince1970: 1616075184)
			)
		)

		// THEN
		XCTAssertFalse(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertTrue(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
		XCTAssertNotNil(cellViewModel.timePublisher.value)
	}

	func testGIVEN_CellModelWithTemporaryMultiDayTraceLocation_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = OnBehalfTraceLocationCellModel(
			traceLocation: .mock(
				description: "Sportstudio",
				address: "Musterstraße 1a, 01234 Musterstadt",
				startDate: Date(timeIntervalSince1970: 1616074184),
				endDate: Date(timeIntervalSince1970: 1617075184)
			)
		)

		// THEN
		XCTAssertFalse(cellViewModel.isInactiveIconHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveContainerViewHiddenPublisher.value)
		XCTAssertTrue(cellViewModel.isActiveIconHidden)
		XCTAssertTrue(cellViewModel.isDurationStackViewHidden)
		XCTAssertTrue(cellViewModel.isButtonHiddenPublisher.value)

		XCTAssertEqual(cellViewModel.title, "Sportstudio")
		XCTAssertEqual(cellViewModel.address, "Musterstraße 1a, 01234 Musterstadt")
		XCTAssertNotNil(cellViewModel.timePublisher.value)
	}

}
