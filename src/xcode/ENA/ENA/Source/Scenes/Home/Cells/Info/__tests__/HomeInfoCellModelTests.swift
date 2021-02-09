////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeInfoCellModelTests: XCTestCase {

	func testGIVEN_HomeInfoCellModel_WHEN_TypeIsInviteFriends_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeInfoCellModel = HomeInfoCellModel(infoCellType: .inviteFriends)

		// THEN
		XCTAssertEqual(homeInfoCellModel.title, AppStrings.Home.infoCardShareTitle)
		XCTAssertEqual(homeInfoCellModel.description, AppStrings.Home.infoCardShareBody)
		XCTAssertEqual(homeInfoCellModel.position, .first)
		XCTAssertEqual(homeInfoCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.infoCardShareTitle)
	}

	func testGIVEN_HomeInfoCellModel_WHEN_TypeIsFaq_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeInfoCellModel = HomeInfoCellModel(infoCellType: .faq)

		// THEN
		XCTAssertEqual(homeInfoCellModel.title, AppStrings.Home.infoCardAboutTitle)
		XCTAssertEqual(homeInfoCellModel.description, AppStrings.Home.infoCardAboutBody)
		XCTAssertEqual(homeInfoCellModel.position, .last)
		XCTAssertEqual(homeInfoCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.infoCardAboutTitle)
	}

	func testGIVEN_HomeInfoCellModel_WHEN_TypeIsAppInformation_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeInfoCellModel = HomeInfoCellModel(infoCellType: .appInformation)

		// THEN
		XCTAssertEqual(homeInfoCellModel.title, AppStrings.Home.appInformationCardTitle)
		XCTAssertNil(homeInfoCellModel.description)
		XCTAssertEqual(homeInfoCellModel.position, .first)
		XCTAssertEqual(homeInfoCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.appInformationCardTitle)
	}

	func testGIVEN_HomeInfoCellModel_WHEN_TypeIsSettings_THEN_InitilizedAsExpected() {
		// GIVEN
		let homeInfoCellModel = HomeInfoCellModel(infoCellType: .settings)

		// THEN
		XCTAssertEqual(homeInfoCellModel.title, AppStrings.Home.settingsCardTitle)
		XCTAssertNil(homeInfoCellModel.description)
		XCTAssertEqual(homeInfoCellModel.position, .last)
		XCTAssertEqual(homeInfoCellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.settingsCardTitle)
	}

}
