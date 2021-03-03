////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeEventCellModelTests: XCTestCase {

	func testGIVEN_HomeEventCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeDiaryCellModel = HomeEventCellModel()

		// THEN
		XCTAssertEqual(homeDiaryCellModel.title, AppStrings.Home.eventCardTitle)
		XCTAssertEqual(homeDiaryCellModel.description, AppStrings.Home.eventCardBody)
		XCTAssertEqual(homeDiaryCellModel.buttonTitle, AppStrings.Home.eventCardButton)
		XCTAssertEqual(homeDiaryCellModel.image, UIImage(named: "Illu_Event"))
		XCTAssertEqual(homeDiaryCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.eventCardButton)
	}
}
