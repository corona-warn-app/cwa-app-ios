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
		app.launchArguments.append(contentsOf: ["-resetFinishedDeltaOnboardings", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}

    func testDeltaOnboardingV15NewFeaturesAndDataDonation() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()

		// - Delta Onboarding 1.5
		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: 5.0))

		let closeButton = app.buttons["AppStrings.AccessibilityLabel.close"]
		XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
		closeButton.tap()

		checkNewFeaturesAndDataDonationScreen()
	}
	
	func test_screenshotDeltaOnboardingV15() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
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
	
	func testDeltaOnboardingNewVersionFeatures() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.12"])
		
		app.launch()

		checkNewFeaturesAndDataDonationScreen()
	}
	
	func test_screenshotDeltaOnboardingNewVersionFeatures() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.12"])
		
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

	// MARK: - Private

	func checkNewFeaturesAndDataDonationScreen() {
		// - New Features Screen
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// - Data Donation Screen
		XCTAssertTrue(app.tables.images["AccessibilityIdentifiers.DataDonation.accImageDescription"].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// - On Home Screen?
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].isHittable)
	}

}
