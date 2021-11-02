////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_05_DataDonation: CWATestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.resetFinishedDeltaOnboardings, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
		app.setLaunchArgument(LaunchArguments.consent.isDatadonationConsentGiven, to: false)
	}

	func test_dataDonationInSettingsWorksCorrectly() {
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)

		app.launch()
		app.swipeUp(velocity: .fast)

		// Navigate to settings
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		settingsLabel.waitAndTap()

		// Navigate to data donation screen
		app.cells[AccessibilityIdentifiers.Settings.dataDonation].waitAndTap()

		// Check that the switch visible
		XCTAssertTrue(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Check that switch is not enabled and thus the cells are not visible
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Enable consent. In consequence, we should see now the federalState cell and the ageGroup cell
		app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitAndTap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Tap on federalState cell. Now we should see the key-value screen and select some.
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.federalStateCell].waitForExistence(timeout: .short))

		// Tap on some data entry. Then we should be back on the data donation screen.
		app.cells.element(boundBy: 7).waitAndTap()
		XCTAssertTrue(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now we want to select a district. So tap onto the district cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.regionCell].waitForExistence(timeout: .short))
		app.cells.element(boundBy: 2).waitAndTap()
		XCTAssertTrue(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))

		// Now we want to select a ageGroup. So tap onto the ageGroup cell, choose one and return to dataDonation.
		app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitAndTap()
		XCTAssertTrue(app.tables[AccessibilityIdentifiers.DataDonation.ageGroupCell].waitForExistence(timeout: .short))
		app.cells.firstMatch.waitAndTap()

		// Now we revoke the consent and make sure, the entry fields are not visible.
		app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitAndTap()

		// Check that switch is not enabled and thus the cells like federalStateName are not visible.
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))

		// Now we enable the consent. In consequence, the entry fields are visible.
		app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitAndTap()
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.regionName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.ageGroup].waitForExistence(timeout: .short))
	}

}
