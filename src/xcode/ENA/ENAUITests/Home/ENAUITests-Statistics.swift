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
		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .S)
		app.launch()
		app.swipeUp()
		
		let title1 = AccessibilityLabels.localized(AppStrings.Statistics.Card.Infections.title)
		let title2 = AccessibilityLabels.localized(AppStrings.Statistics.Card.Incidence.title)
		let title3 = AccessibilityLabels.localized(AppStrings.Statistics.Card.KeySubmissions.title)
		let title4 = AccessibilityLabels.localized(AppStrings.Statistics.Card.ReproductionNumber.title)

		XCTAssert(app.staticTexts[title1].waitForExistence(timeout: .short))
		XCTAssert(app.staticTexts[title2].waitForExistence(timeout: .zero))
		XCTAssert(app.staticTexts[title3].waitForExistence(timeout: .zero))
		XCTAssert(app.staticTexts[title4].waitForExistence(timeout: .zero))
				
	}
}
