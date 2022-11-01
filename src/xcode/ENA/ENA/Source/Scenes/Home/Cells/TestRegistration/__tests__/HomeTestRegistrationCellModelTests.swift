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
		XCTAssertEqual(cellModel.subtitle, AppStrings.Home.TestRegistration.subtitle)
		XCTAssertEqual(cellModel.description, AppStrings.Home.TestRegistration.description)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.TestRegistration.button)
		XCTAssertEqual(cellModel.image, UIImage(named: "Illu_WarningAfterSelfTest-initial"))
		XCTAssertEqual(cellModel.gradientViewType, .bottomLightBlueToTopWhite)
		XCTAssertEqual(cellModel.buttonAccessibilityIdentifier, AccessibilityIdentifiers.Home.submitCardButton)
	}

}
