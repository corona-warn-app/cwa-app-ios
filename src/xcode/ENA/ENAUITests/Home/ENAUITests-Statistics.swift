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
		let title1 = AccessibilityIdentifiers.Statistics.Infections
		let title2 = AccessibilityIdentifiers.Statistics.Incidence
		let title3 = AccessibilityIdentifiers.Statistics.KeySubmissions
		let title4 = AccessibilityIdentifiers.Statistics.ReproductionNumber

		// WHEN
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp(velocity: .slow)

		// THEN
		XCTAssert(app.staticTexts[title1].waitForExistence(timeout: .medium))
		XCTAssert(app.staticTexts[title2].exists)
		XCTAssert(app.staticTexts[title3].exists)
		XCTAssert(app.staticTexts[title4].exists)
	}
	
}
