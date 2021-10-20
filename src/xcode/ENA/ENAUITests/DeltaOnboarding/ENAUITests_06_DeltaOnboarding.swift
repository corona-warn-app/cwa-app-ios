//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_06_DeltaOnboarding: CWATestCase {

	// MARK: - Attributes.
	
	var app: XCUIApplication!

	// MARK: - Setup.

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.resetFinishedDeltaOnboardings, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
		app.setLaunchArgument(LaunchArguments.consent.isDatadonationConsentGiven, to: false)
	}

	// MARK: - Tests

    func testDeltaOnboardings() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.4")
		
		app.launch()
		
		checkNewFeaturesScreen()
		skipNotificationReworkScreen()
		checkCrossCountrySupport()
		checkDataDonationScreen()
		
		// On Home Screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
	}
	
	func testDeltaOnboardingNewVersionFeatures() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.12")
		
		app.launch()

		checkNewFeaturesScreen()
		
		// On Home Screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .short))
	}

	func test_DeltaOnboardingNewVersionFeatures() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.13")
		
		app.launch()

		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
	}
	
	func test_DeltaOnboardingNotificationRework() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "2.11")
		
		app.launch()
		
		checkNewFeaturesScreen()

		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.description].waitForExistence(timeout: .short))
	}
	
	func test_DeltaOnboardingV15() throws {
		app.setLaunchArgument(LaunchArguments.onboarding.onboardingVersion, to: "1.4")
		
		app.launch()
		
		checkNewFeaturesScreen()
		skipNotificationReworkScreen()
		
		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: .medium))
	}

	// MARK: - Private
	
	func checkCrossCountrySupport() {
		// - Delta Onboarding 1.5
		XCTAssertTrue(app.tables.images["AppStrings.DeltaOnboarding.accImageLabel"].waitForExistence(timeout: .medium))

		// leave screen.
		app.buttons[AccessibilityIdentifiers.DeltaOnboarding.primaryButton].waitAndTap()
	}
			
	private func checkDataDonationScreen() {
		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// We should only see the two fields. The region should be visible if we tapped on federal state.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Tap on federalState cell. Now we should see the key-value screen and select some.
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.federalStateCell].waitForExistence(timeout: .short))

		// Tap on some data entry. Then we should be back on the data donation screen.
		app.cells.element(boundBy: 7).waitAndTap()

		// Now we should see the three data fields.
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.regionCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 8).waitAndTap()

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 2).waitAndTap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// leave screen
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
	}
	
	func checkNewFeaturesScreen() {
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription].waitForExistence(timeout: .medium))
		// leave screen
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()
	}
	
	private func skipNotificationReworkScreen() {
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn].waitForExistence(timeout: .short))
		// leave screen
		app.buttons[AccessibilityIdentifiers.NotificationSettings.close].waitAndTap()
	}
}
