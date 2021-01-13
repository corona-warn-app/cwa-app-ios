////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeDiaryCellModelTests: XCTestCase {

	func testGIVEN_HomeDiaryCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeDiaryCellModel = HomeDiaryCellModel()

		// THEN
		XCTAssertEqual(homeDiaryCellModel.title, AppStrings.Home.diaryCardTitle)
		XCTAssertEqual(homeDiaryCellModel.description, AppStrings.Home.diaryCardBody)
		XCTAssertEqual(homeDiaryCellModel.buttonTitle, AppStrings.Home.diaryCardButton)
		XCTAssertEqual(homeDiaryCellModel.image, UIImage(named: "Illu_Diary"))
		XCTAssertEqual(homeDiaryCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.diaryCardButton)
	}
}
