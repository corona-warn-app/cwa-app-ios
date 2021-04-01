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

	func testCheckinInfoScreen_navigate_to_dataPrivacy() throws {
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
		snapshot("CheckInInfoScreen")
		
		// Navigate to Data Privacy
//		XCTAssertFalse(app.staticTexts["AppStrings.AppInformation.privacyTitle"].exists)
		if let target = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.CheckinInformation.dataPrivacyTitle, element: app, app: app) {
			target.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.CheckinInformation.dataPrivacyTitle)")
		}

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
	}

	func testCheckinInfoScreen_confirmConsent() throws {
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "NO"])
		app.launch()

		// Home screen
		if let element = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Tabbar.checkin, element: app, app: app)	{
			// Navigate to CheckIn
			element.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Tabbar.checkin)")
		}

		// Confirm consent
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.CheckinInformation.primaryButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.CheckinInformation.primaryButton].tap()
		
		snapshot("CheckIn_MyCheckins")
		
		// verify elements on the following screen – pending
    }

}
