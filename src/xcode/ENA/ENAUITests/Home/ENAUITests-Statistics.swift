////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_Statistics: XCTestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}

	func test_StatisticsCardTitles() throws {
		// GIVEN
		let title1 = AccessibilityIdentifiers.Statistics.Card.Infections.title
		let title2 = AccessibilityIdentifiers.Statistics.Card.Incidence.title
		let title3 = AccessibilityIdentifiers.Statistics.Card.KeySubmissions.title
		let title4 = AccessibilityIdentifiers.Statistics.Card.ReproductionNumber.title

		// WHEN
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp()

		// THEN
		XCTAssert(app.staticTexts[title1].waitForExistence(timeout: .short))
		XCTAssert(app.staticTexts[title2].waitForExistence(timeout: .zero))
		XCTAssert(app.staticTexts[title3].waitForExistence(timeout: .zero))
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .zero))
	}
	
}
