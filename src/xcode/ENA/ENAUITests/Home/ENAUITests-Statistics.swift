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
		let title1 = AccessibilityIdentifiers.Statistics.infections
		let title2 = AccessibilityIdentifiers.Statistics.incidence
		let title3 = AccessibilityIdentifiers.Statistics.keySubmissions
		let title4 = AccessibilityIdentifiers.Statistics.reproductionNumber

		// WHEN
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp()

		// THEN
		let cell = app.cells[AccessibilityIdentifiers.Statistics.cell]
		XCTAssertTrue(cell.exists)
		XCTAssert(cell.staticTexts[title1].exists)
		XCTAssert(cell.staticTexts[title2].exists)
		XCTAssert(cell.staticTexts[title3].exists)
		XCTAssert(cell.staticTexts[title4].exists)
	}
	
}
