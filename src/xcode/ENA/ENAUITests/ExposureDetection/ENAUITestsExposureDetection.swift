////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsExposureDetection: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
		app.launchArguments.append(contentsOf: ["-riskLevel", "high"])
	}

	func test_NavigationToSurvey() throws {
		launch()

		// Tap risk card and wait for exposure details.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].tap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitForExistence(timeout: .long))

		// Scroll to and tap survey card.
		app.scrollToElement(element: app.cells[AccessibilityIdentifiers.ExposureDetection.surveyCardCell])
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ExposureDetection.surveyCardCell].waitForExistence(timeout: .long))
		app.cells[AccessibilityIdentifiers.ExposureDetection.surveyCardCell].tap()

		// Tap the survey start button.
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.SurveyConsent.acceptButton].waitForExistence(timeout: .long))
		app.buttons[AccessibilityIdentifiers.SurveyConsent.acceptButton].tap()

		// Wait for safari.
		let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
		XCTAssertTrue(safari.wait(for: .runningForeground, timeout: .long))
	}

	private func launch() {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))
	}

}
