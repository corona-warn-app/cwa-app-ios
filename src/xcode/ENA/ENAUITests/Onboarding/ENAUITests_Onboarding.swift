//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_Onboarding: CWATestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: false)
		app.setLaunchArgument(LaunchArguments.consent.isDatadonationConsentGiven, to: false)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.unknown.stringValue)
	}

	func test_0000_OnboardingFlow_DisablePermissions_normal_XXXL() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .XXXL)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()

		// data consent switch must only be visible on settings-data-donation.
		
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
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 7).waitAndTap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now proceed with onboarding
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitAndTap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
	}

	func test_0001_OnboardingFlow_EnablePermissions_normal_XS() throws {
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .XS)
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()

		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		// data consent switch must only be visible on settings-data-donation.
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
		app.cells.element(boundBy: 7).waitAndTap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		XCTAssertFalse(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now proceed with onboarding
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.General.secondaryFooterButton].waitAndTap()

		// check that the homescreen element AppStrings.home.activateTitle is visible onscreen
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
	}

	
	// MARK: - Screenshots

	func test_0002_Screenshots_OnboardingFlow_EnablePermissions_normal_S() throws {
		var screenshotCounter = 0
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: true)
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		
		let prefix = "OnboardingFlow_EnablePermission_"
		
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitAndTap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitAndTap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		snapshot(prefix + (String(format: "%04d", (screenshotCounter.inc() ))))
		
//		Onboarding ends here. Next screen is the home screen.
	}
}
