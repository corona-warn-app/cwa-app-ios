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
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: YES)
		app.setLaunchArgument(LaunchArguments.onboarding.resetFinishedDeltaOnboardings, to: YES)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: NO)
		app.setLaunchArgument(LaunchArguments.consent.isDatadonationConsentGiven, to: NO)
	}

    func testDeltaOnboardingV15NewFeaturesAndDataDonation() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.4")
		
		app.launch()

		// - Delta Onboarding 1.5
		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: .medium))

		let closeButton = app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close]
		closeButton.waitAndTap()

		checkNewFeaturesAndDataDonationScreen()
	}
	
	func testDeltaOnboardingNewVersionFeatures() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.12")
		
		app.launch()

		checkNewFeaturesAndDataDonationScreen()
	}

	// MARK: - Screenshots

	func test_screenshot_DeltaOnboardingV15() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.4")
		
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
	
	func test_screenshot_DeltaOnboardingNewVersionFeatures() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.13")
		
		app.launch()
		
		var screenshotCounter = 0
		let screenshotLabel = "deltaOnboarding_newVersionFeatures"

		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
		
		snapshot("\(screenshotLabel)_\(String(format: "%04d", (screenshotCounter.inc() )))")
	}

	// MARK: - Private

	func checkNewFeaturesAndDataDonationScreen() {
//		// - New Features Screen
//		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
//		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
//
//		// - Data Donation Screen
//		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))
//
//		// We should only see the two fields. The region should be visible if we tapped on federal state.
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
//		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))
//
//		// Tap on federalState cell. Now we should see the key-value screen and select some.
//		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitAndTap()
//		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.federalStateCell].waitForExistence(timeout: .short))
//
//		// Tap on some data entry. Then we should be back on the data donation screen.
//		app.cells.element(boundBy: 7).waitAndTap()
//
//		// Now we should see the three data fields.
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))
//
//		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
//		app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitAndTap()
//		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.regionCell].waitForExistence(timeout: .short))
//		app.cells.element(boundBy: 8).waitAndTap()
//
//		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
//		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitAndTap()
//		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
//		app.cells.element(boundBy: 7).waitAndTap()
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))
//
//		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))
//
//
//		// Now proceed with delta onboarding
//		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
//
//		// - On Home Screen?
//		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
	}

}
