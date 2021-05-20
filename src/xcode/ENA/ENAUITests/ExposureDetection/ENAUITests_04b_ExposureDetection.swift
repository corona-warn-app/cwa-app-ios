////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_04b_ExposureDetection: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.isOnboarded, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.onboarding.setCurrentOnboardingVersion, YES])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, NO])
		app.launchArguments.append(contentsOf: [UITestingLaunchArguments.risk.riskLevel, "high"])
	}

	func test_NavigationToSurvey() throws {
		launch()

		// Tap risk card and wait for exposure details.
		app.cells.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitAndTap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .long))

		// Scroll to and tap survey card.
		let surveyCard = app.cells[AccessibilityIdentifiers.ExposureDetection.surveyCardCell]
		surveyCard.waitAndTap()

		// Tap the survey start button.
		app.buttons[AccessibilityIdentifiers.SurveyConsent.acceptButton].waitAndTap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

}
