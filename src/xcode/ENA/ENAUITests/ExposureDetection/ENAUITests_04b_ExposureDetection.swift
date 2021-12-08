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

		// Scroll to and tap iButton from cell
		let iButton = app.cells[AccessibilityIdentifiers.ExposureDetection.detailsGuideHygiene].buttons.firstMatch
		iButton.waitAndTap()
	}

	func test_navigateToInformationGuideHome() throws {
		launch()

		// Tap risk card and wait for exposure details.
		app.cells.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitAndTap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .long))

		// Scroll to and tap iButton from cell
		let iButton = app.cells[AccessibilityIdentifiers.ExposureDetection.detailsGuideHome].buttons.firstMatch
		iButton.waitAndTap()
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

}
