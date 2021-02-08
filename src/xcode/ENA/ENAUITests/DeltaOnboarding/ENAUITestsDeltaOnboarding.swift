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

		let tablesQuery = app.tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
				
		// Close (X) Button
		XCTAssertTrue(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()

		// On homescreen?
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
	}
	
	func test_screenshotDeltaOnboardingV15View() throws {
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
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_V15"
		
		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
		app.swipeUp()
	}
	
	func testDeltaOnboardingNewVersionFeaturesView() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.11"])
		
		app.launch()
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}

		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.newVersionFeaturesAccImageLabel"].waitForExistence(timeout: 5.0))
	}
	
	func test_screenshotDeltaOnboardingNewVersionFeaturesView() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.11"])
		
		app.launch()
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_newVersionFeatures"
		
		// The "Information zur Funktionsweise der Risiko-Ermittlung"
		// appears on fresh installs (e.g. every CI-run) but not on already started apps.
		// We dismiss it if present.
		let alert = app.alerts.firstMatch
		if alert.exists {
			alert.buttons.firstMatch.tap()
		}

		let tablesQuery = XCUIApplication().tables
		XCTAssertTrue(tablesQuery.images["AppStrings.DeltaOnboarding.newVersionFeaturesAccImageLabel"].waitForExistence(timeout: 5.0))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

}
