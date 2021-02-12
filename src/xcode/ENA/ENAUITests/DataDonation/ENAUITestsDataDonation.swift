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
	}

	// Tests if the data donation screen is shown during the onboarding (to be exact: as the last screen of the onboarding).
	func test_NavigationThroughOnboardingShowsDataDonation() throws {
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])

		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: 5.0))

		// tap through the onboarding screens
		// snapshot("ScreenShot_\(#function)_0000")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		// snapshot("ScreenShot_\(#function)_0001")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0002")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		// snapshot("ScreenShot_\(#function)_0003")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		// snapshot("ScreenShot_\(#function)_0004")
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingDoNotAllow"].tap()

		// check now that the data donation is shown
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))


	}

	// Tests if the data donation screen is shown during the delta onboarding.
	func test_NavigationThroughDeltaOnboardingShowsDataDonation() throws {
		launch()
	}

	// Tests if the data donation screen is shown at the settings and if the screen has the different behavior as the one in the onboarding.
	func test_NavigationToSettingsDataDonation() throws {
		launch()
	}

	// Tests if the data in the onboarding data donation screen is set is shown correctly in the settings data donation.
	func test_SetValuesInOnboardingAreSetInSettings() throws {
		launch()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

}
