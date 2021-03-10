//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_05_ExposureLogging: XCTestCase {
	
	var app: XCUIApplication!

    override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_screenshot_exposureLogging() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
		
		app.cells["AppStrings.Home.activateCardOnTitle"].tap()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		
		app.swipeUp()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	func test_screenshot_exposureLoggingOff() throws {
		var screenshotCounter = 0
		app.setPreferredContentSizeCategory(accessibility: .accessibility, size: .XS)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.unknown.stringValue])
		app.launch()

		// only run if home screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.cells["AppStrings.Home.activateCardOffTitle"].tap()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")

		app.swipeUp()
		snapshot("exposureloggingscreen_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}
}
