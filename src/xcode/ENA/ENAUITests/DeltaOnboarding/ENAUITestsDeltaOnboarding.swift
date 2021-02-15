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
		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: .medium))

		let closeButton = app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close]
		XCTAssertTrue(closeButton.waitForExistence(timeout: .medium))
		closeButton.tap()

		checkNewFeaturesAndDataDonationScreen()
	}
	
	func test_screenshotDeltaOnboardingV15() throws {
		app.launchArguments.append(contentsOf: ["-onboardingVersion", "1.4"])
		
		app.launch()
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_V15"

		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: .medium))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")
		app.swipeUp()
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc())))")
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

		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	// MARK: - Private

	func checkNewFeaturesAndDataDonationScreen() {
		// - New Features Screen
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// - Data Donation Screen
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DataDonation.accImageDescription].waitForExistence(timeout: .medium))

		app.swipeUp(velocity: .slow)
		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// We should only see the two fields. The region should be visible if we tapped on federal state.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Tap on federalState cell. Now we should see the key-value screen and select some.
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].tap()
		XCTAssertTrue(app.navigationBars[app.localized(AppStrings.DataDonation.ValueSelection.Title.FederalState)].waitForExistence(timeout: .short))

		// Tap on some data entry. Then we should be back on the data donation screen.
		app.cells.element(boundBy: 7).tap()

		// Now we should see the three data fields.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.regionName].tap()
		XCTAssertTrue(app.navigationBars[app.localized(AppStrings.DataDonation.ValueSelection.Title.Region)].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 8).tap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].tap()
		XCTAssertTrue(app.navigationBars[app.localized(AppStrings.DataDonation.ValueSelection.Title.Age)].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 7).tap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now proceed with delta onboarding
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		// - On Home Screen?
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
	}

}
