//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_06_DeltaOnboarding: XCTestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
	}

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}

		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		
		// Close (X) Button
		XCTAssertTrue(XCUIApplication().navigationBars["ENA.DeltaOnboardingV15View"].buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5))
		
		// Continue Button
		XCTAssertTrue(XCUIApplication().buttons["AppStrings.DeltaOnboarding.primaryButton"].waitForExistence(timeout: 5))
		XCUIApplication().buttons["AppStrings.DeltaOnboarding.primaryButton"].tap()
	}
	
	func test_screenshotDeltaOnboardingV15View() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_V15"
		
		
		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("homescreenrisk_level_\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		
	}

}
