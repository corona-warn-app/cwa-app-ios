//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_02_AppInformation: XCTestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test_0020_AppInformationFlow() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.aboutNavigation].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.faqNavigation].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.contactNavigation].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.privacyNavigation].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.termsNavigation].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.navigation].waitForExistence(timeout: 5.0))
	}

	func test_0021_AppInformationFlow_about() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells["AppStrings.AppInformation.aboutNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.aboutNavigation"].tap()

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.aboutTitle"].waitForExistence(timeout: 5.0))
	}

	func test_0022_AppInformationFlow_faq() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: .medium))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells["AppStrings.AppInformation.faqNavigation"].waitForExistence(timeout: .medium))
		app.cells["AppStrings.AppInformation.faqNavigation"].tap()

		XCTAssertTrue(app.webViews.firstMatch.waitForExistence(timeout: .medium))
	}

	func test_0023_AppInformationFlow_contact() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells["AppStrings.AppInformation.contactNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.contactNavigation"].tap()

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.contactTitle"].waitForExistence(timeout: 5.0))
	}

	func test_0024_AppInformationFlow_privacy() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells["AppStrings.AppInformation.privacyNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.privacyNavigation"].tap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.privacyImageDescription"].waitForExistence(timeout: 5.0))
	}

	func test_0025_AppInformationFlow_terms() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp(velocity: .fast)
		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells["AppStrings.AppInformation.termsNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.termsNavigation"].tap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.termsImageDescription"].waitForExistence(timeout: 5.0))
	}
	
	func test_0026_AppInformationFlow_ErrorReports() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		// assert cells
		XCTAssertTrue(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.navigation].waitForExistence(timeout: 5.0))
		app.cells[AccessibilityIdentifiers.ErrorReport.navigation].tap()
		app.swipeUp(velocity: .fast)

//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: 5.0))
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.faq].waitForExistence(timeout: 5.0))
//		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].waitForExistence(timeout: 5.0))

	}
}
