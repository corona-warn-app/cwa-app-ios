////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class MissingPermissionsCellModelTests: XCTestCase {

	func testGIVEN_CellModel_THEN_InitialStateIsAsExpected() {
		// GIVEN
		let cellViewModel = MissingPermissionsCellModel()

		// THEN
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary1))
		XCTAssertTrue(cellViewModel.isButtonEnabledPublisher.value)
	}

	func testGIVEN_CellModel_WHEN_SetEnabled_THEN_TextColorAndButtonStateChange() {
		// GIVEN
		let cellViewModel = MissingPermissionsCellModel()

		// WHEN
		cellViewModel.setEnabled(false)

		// THEN
		XCTAssertEqual(cellViewModel.textColorPublisher.value, UIColor.enaColor(for: .textPrimary2))
		XCTAssertFalse(cellViewModel.isButtonEnabledPublisher.value)
	}

}
