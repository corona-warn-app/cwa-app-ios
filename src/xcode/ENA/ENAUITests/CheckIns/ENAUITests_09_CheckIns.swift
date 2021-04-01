////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_09_CheckIns: XCTestCase {
	
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
		
		// Navigate to CheckIn
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
		// Confirm consent
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.CheckinInformation.primaryButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.CheckinInformation.primaryButton].tap()
		
		snapshot("CheckIn_MyCheckins")
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.Overview.title)].waitForExistence(timeout: .short))
	}
	
	func test_QRCodeScanOpened() throws {
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "YES"])
		app.launch()
		
		// Navigate to CheckIn
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.Overview.emptyTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.Overview.emptyDescription)].exists)
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].exists)
		
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].tap()


		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionQRScanner.flash"].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.ExposureSubmissionQRScanner.title)].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.QRScanner.instruction)].exists)

	}
}
