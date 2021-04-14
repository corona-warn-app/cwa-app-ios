////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeTestRegistrationCellModelTests: XCTestCase {

	func testGIVEN_HomeTestRegistrationCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let cellModel = HomeTestRegistrationCellModel()

		// THEN
		XCTAssertEqual(cellModel.title, AppStrings.Home.submitCardTitle)
		XCTAssertEqual(cellModel.description, AppStrings.Home.submitCardBody)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.submitCardButton)
		XCTAssertEqual(cellModel.image, UIImage(named: "Illu_Hand_with_phone-initial"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.submitCardButton)
	}

}
