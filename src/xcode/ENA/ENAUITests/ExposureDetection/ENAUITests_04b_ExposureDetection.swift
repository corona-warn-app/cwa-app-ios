////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_04b_ExposureDetection: CWATestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
		app.setLaunchArgument(LaunchArguments.risk.riskLevel, to: "high")
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

	func test_navigateToInformationGuideHygiene() throws {
		launch()

		// Tap risk card and wait for exposure details.
		app.cells.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitAndTap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .long))

		// Scroll to and tap iButton from first cell
		let iButtonFirst = app.cells[AccessibilityIdentifiers.ExposureDetection.detailsGuideHygiene].buttons.firstMatch
		iButtonFirst.waitAndTap()

		// Details screen - not we may have multiple
		let closeButton = app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close + "HygieneRules"]
		closeButton.waitAndTap()

		// Scroll to and tap iButton from second cell
		let iButtonSecond = app.cells[AccessibilityIdentifiers.ExposureDetection.detailsGuideHome].buttons.firstMatch
		iButtonSecond.waitAndTap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

}
