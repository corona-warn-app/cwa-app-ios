////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeTestRegistrationCellModelTests: CWATestCase {

	func testGIVEN_HomeTestRegistrationCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let cellModel = HomeTestRegistrationCellModel()

		// THEN
		XCTAssertEqual(cellModel.title, AppStrings.Home.TestRegistration.title)
		XCTAssertEqual(cellModel.description, AppStrings.Home.TestRegistration.description)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.TestRegistration.button)
		XCTAssertEqual(cellModel.image, UIImage(named: "Illu_Hand_with_phone-initial"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.submitCardButton)
	}

}
