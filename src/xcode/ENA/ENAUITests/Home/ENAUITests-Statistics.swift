////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_01b_Statistics: CWATestCase {
	var app: XCUIApplication!
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
	}
	
	func test_StatisticsCardTitles() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title2 = AccessibilityIdentifiers.Statistics.Infections.title
		let title3 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let title5 = AccessibilityIdentifiers.Statistics.AtLeastOneVaccination.title
		let title6 = AccessibilityIdentifiers.Statistics.FullyVaccinated.title
		let title7 = AccessibilityIdentifiers.Statistics.Doses.title

		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title7].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title6].waitForExistence(timeout: .medium))
			app.staticTexts[title6].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title5].waitForExistence(timeout: .medium))
			app.staticTexts[title5].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeRight()
		default:
			XCTAssertTrue(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title5].waitForExistence(timeout: .medium))
			app.staticTexts[title5].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title6].waitForExistence(timeout: .medium))
			app.staticTexts[title6].swipeLeft()
			XCTAssertTrue(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title7].swipeRight()

		}
	}
	
	func test_StatisticsCardInfoButtons() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Infections.title
		let title2 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title3 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)
		
		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			cardReproductionNumberInfoScreenTest(title4)
			app.staticTexts[title4].swipeLeft()

			cardIncidenceInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()

			cardKeySubmissionsInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()

			cardInfectionsInfoScreenTest(title1)
			app.staticTexts[title1].swipeRight()

		default:
			cardInfectionsInfoScreenTest(title1)
			app.staticTexts[title1].swipeLeft()
			
			cardKeySubmissionsInfoScreenTest(title2)
			app.staticTexts[title2].swipeLeft()
			
			cardIncidenceInfoScreenTest(title3)
			app.staticTexts[title3].swipeLeft()
			
			cardReproductionNumberInfoScreenTest(title4)
			app.staticTexts[title4].swipeRight()
		}
	}
	
	// MARK: - Screenshots

	func test_screenshot_statistics_card_titles() throws {
		// GIVEN
		let infectionsTitle = AccessibilityIdentifiers.Statistics.Infections.title
		let keySubmissionsTitle = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let incidenceTitle = AccessibilityIdentifiers.Statistics.Incidence.title
		let reproductionNumberTitle = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)
		var screenshotCounter = 0

		// WHEN
		app.setPreferredContentSizeCategory(accessibility: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)

		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssert(self.app.staticTexts[reproductionNumberTitle].waitForExistence(timeout: .medium))
			app.staticTexts[reproductionNumberTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[incidenceTitle].waitForExistence(timeout: .medium))
			app.staticTexts[incidenceTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[keySubmissionsTitle].waitForExistence(timeout: .medium))
			app.staticTexts[keySubmissionsTitle].swipeLeft()
			cardKeySubmissionsInfoScreenTest(keySubmissionsTitle)
			XCTAssert(self.app.staticTexts[infectionsTitle].waitForExistence(timeout: .medium))
			cardInfectionsInfoScreenTest(infectionsTitle)
			app.staticTexts[infectionsTitle].swipeRight()
		default:
			XCTAssert(self.app.staticTexts[infectionsTitle].waitForExistence(timeout: .medium))
			app.staticTexts[infectionsTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[keySubmissionsTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_persons_warned")
			app.staticTexts[keySubmissionsTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[incidenceTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_7Day_incidence")
			app.staticTexts[incidenceTitle].swipeLeft()
			XCTAssert(self.app.staticTexts[reproductionNumberTitle].waitForExistence(timeout: .medium))
			snapshot("statistics_7Day_rvalue")
			cardReproductionNumberOpenInfoScreen(reproductionNumberTitle)
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
			app.swipeUp(velocity: .slow)
			snapshot("statistics_info_screen_\(String(format: "%04d", (screenshotCounter.inc() )))")
		}
	}

	// MARK: - Private
	
	private func cardInfectionsInfoScreenTest(_ title1: String) {
		XCTAssertTrue(app.staticTexts[title1].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Infections.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardKeySubmissionsInfoScreenTest(_ title2: String) {
		XCTAssertTrue(app.staticTexts[title2].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardIncidenceInfoScreenTest(_ title3: String) {
		XCTAssertTrue(app.staticTexts[title3].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.Incidence.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardReproductionNumberInfoScreenTest(_ title4: String) {
		XCTAssertTrue(app.staticTexts[title4].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].waitAndTap()
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
	}
	
	private func cardReproductionNumberOpenInfoScreen(_ title4: String) {
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .medium))
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].waitAndTap()
	}
}
