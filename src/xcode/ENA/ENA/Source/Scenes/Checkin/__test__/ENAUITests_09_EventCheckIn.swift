////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_09_EventCheckIn: XCTestCase {

	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		
	}

    func testCheckinInfoScreen() throws {
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "NO"])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.CheckinInformation.acknowledgementTitle].exists)
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.CheckinInformation.dataPrivacyTitle].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.CheckinInformation.primaryButton].exists)
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.CheckinInformation.descriptionTitle].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.CheckinInformation.descriptionSubHeadline].exists)
		
		// Navigate to Data Privacy
//		app.swipeUp()
//		XCTAssertFalse(app.staticTexts["AppStrings.AppInformation.privacyTitle"].exists)
//		app.cells[AccessibilityIdentifiers.CheckinInformation.dataPrivacyTitle].tap()
//		
//		let x = AccessibilityLabels.accIdentifiersOfElement(app.cells)
//		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
    }

}
