////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_08_UpdateOSUITests: XCTestCase {

	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-showUpdateOS", "YES"])
	}
	
	func test_screenshot_UpdateOS() {
		app.launch()
		
		XCTAssert(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.text] .waitForExistence(timeout: .short))
		XCTAssert(app.staticTexts[AccessibilityIdentifiers.UpdateOSScreen.title] .waitForExistence(timeout: .short))
		XCTAssert(app.images[AccessibilityIdentifiers.UpdateOSScreen.logo] .waitForExistence(timeout: .short))
		XCTAssert(app.images[AccessibilityIdentifiers.UpdateOSScreen.mainImage] .waitForExistence(timeout: .short))

		snapshot("UpdateOS")
	}

}
