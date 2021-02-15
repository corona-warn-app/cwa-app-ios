////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsDataDonation: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-resetFinishedDeltaOnboardings", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
		app.launchArguments.append(contentsOf: ["-isDatadonationConsentGiven", "NO"])
	}

	func test_navigationToDatadonation() {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])

		app.launch()
		app.swipeUp(velocity: .fast)

		XCTAssert(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.Settings.Datadonation.description"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Settings.Datadonation.description"].tap()

		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.DataDonation.accImageDescription].waitForExistence(timeout: .medium))
		app.swipeUp(velocity: .slow)

		XCTAssertFalse(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .short))
		XCTAssertTrue(app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].waitForExistence(timeout: .short))
		app.switches[AccessibilityIdentifiers.DataDonation.consentSwitch].tap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].waitForExistence(timeout: .medium))
		app.cells[AccessibilityIdentifiers.DataDonation.federalStateName].tap()
	}

}
