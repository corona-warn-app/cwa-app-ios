////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class AddTraceLocationCellModelTests: XCTestCase {

	func testGIVEN_CellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = AddTraceLocationCellModel()

		// THEN
		XCTAssertEqual(cellViewModel.text, AppStrings.TraceLocations.Overview.addButtonTitle)
		XCTAssertEqual(cellViewModel.iconImagePublisher.value, UIImage(named: "Icon_Add"))
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary1))
	}

	func testGIVEN_CellModel_WHEN_SetEnabled_THEN_TextColorAndButtonStateChange() {
		// GIVEN
		let cellViewModel = AddTraceLocationCellModel()

		// WHEN
		cellViewModel.setEnabled(false)

		// THEN
		XCTAssertEqual(cellViewModel.iconImagePublisher.value, UIImage(named: "Icon_Add_Grey"))
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary2))
	}

}
