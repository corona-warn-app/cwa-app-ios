////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsAntigenTestProfile: XCTestCase {
	
	// MARK: - Overrides

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}
	
	// MARK: - Internal

	var app: XCUIApplication!
	
	// MARK: - Tests
	
	func test_() throws {
		
		app.launch()
		app.swipeUp(velocity: .fast)


		let button = try XCTUnwrap(app.cells[AccessibilityIdentifiers.Home.submitCardButton]).waitForExistence(timeout: .short)
		button.tap()
	}
}
