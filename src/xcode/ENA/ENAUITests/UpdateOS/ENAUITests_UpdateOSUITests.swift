////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_UpdateOS: CWATestCase {

	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.infoScreen.showUpdateOS, to: true)
	}
	
	// MARK: - Screenshots

	func test_UpdateOS() {
		app.launch()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.text] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.title] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.UpdateOSScreen.logo] .waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.UpdateOSScreen.mainImage] .waitForExistence(timeout: .short))
	}

}
