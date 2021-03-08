////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeTraceLocationsCellModelTests: XCTestCase {

	func testGIVEN_HomeTraceLocationsCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let cellModel = HomeTraceLocationsCellModel()

		// THEN
		XCTAssertEqual(cellModel.title, AppStrings.Home.eventCardTitle)
		XCTAssertEqual(cellModel.description, AppStrings.Home.eventCardBody)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.eventCardButton)
		XCTAssertEqual(cellModel.image, UIImage(named: "Illu_Event"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.eventCardButton)
	}
}
