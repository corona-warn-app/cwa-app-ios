////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_Statistics: XCTestCase {
	var app: XCUIApplication!
	
	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}
	
	func test_StatisticsCardTitles() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Infections.title
		let title2 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title3 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)

		// WHEN
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssert(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssert(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssert(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssert(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeRight()
		default:
			XCTAssert(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeLeft()
			XCTAssert(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			XCTAssert(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssert(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeRight()
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
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
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
	
	func test_screenshot_statisticsCardTitles() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Infections.title
		let title2 = AccessibilityIdentifiers.Statistics.KeySubmissions.title
		let title3 = AccessibilityIdentifiers.Statistics.Incidence.title
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber.title
		let layoutDirection = UIView.userInterfaceLayoutDirection(for: UIView().semanticContentAttribute)

		// WHEN
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)
		
		// THEN
		switch layoutDirection {
		case .rightToLeft:
			XCTAssert(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			app.staticTexts[title4].swipeLeft()
			XCTAssert(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			app.staticTexts[title3].swipeLeft()
			XCTAssert(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			app.staticTexts[title2].swipeLeft()
			cardKeySubmissionsInfoScreenTest(title2)
			XCTAssert(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			cardInfectionsInfoScreenTest(title1)
			app.staticTexts[title1].swipeRight()
		default:
			XCTAssert(self.app.staticTexts[title1].waitForExistence(timeout: .medium))
			app.staticTexts[title1].swipeLeft()
			XCTAssert(self.app.staticTexts[title2].waitForExistence(timeout: .medium))
			snapshot("statistics_persons_warned")
			app.staticTexts[title2].swipeLeft()
			XCTAssert(self.app.staticTexts[title3].waitForExistence(timeout: .medium))
			snapshot("statistics_7Day_incidence")
			app.staticTexts[title3].swipeLeft()
			XCTAssert(self.app.staticTexts[title4].waitForExistence(timeout: .medium))
			snapshot("statistics_7Day_rvalue")
			cardReproductionNumberOpenInfoScreen(title4)
			snapshot("statistics_info_screen")
			app.staticTexts[title4].swipeRight()
		}
	}

	// MARK: - Private
	
	private func cardInfectionsInfoScreenTest(_ title1: String) {
		XCTAssert(app.staticTexts[title1].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons[AccessibilityIdentifiers.Statistics.Infections.infoButton].exists)
		app.buttons[AccessibilityIdentifiers.Statistics.Infections.infoButton].tap()
		XCTAssert(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: .short))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
	}
	
	private func cardKeySubmissionsInfoScreenTest(_ title2: String) {
		XCTAssert(app.staticTexts[title2].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons[AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton].exists)
		app.buttons[AccessibilityIdentifiers.Statistics.KeySubmissions.infoButton].tap()
		XCTAssert(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: .short))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
	}
	
	private func cardIncidenceInfoScreenTest(_ title3: String) {
		XCTAssert(app.staticTexts[title3].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons[AccessibilityIdentifiers.Statistics.Incidence.infoButton].exists)
		app.buttons[AccessibilityIdentifiers.Statistics.Incidence.infoButton].tap()
		XCTAssert(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: .short))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
	}
	
	private func cardReproductionNumberInfoScreenTest(_ title4: String) {
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].exists)
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].tap()
		XCTAssert(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: .short))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
	}

	private func cardReproductionNumberOpenInfoScreen(_ title4: String) {
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .medium))
		XCTAssert(app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].exists)
		app.buttons[AccessibilityIdentifiers.Statistics.ReproductionNumber.infoButton].tap()
	}
}
