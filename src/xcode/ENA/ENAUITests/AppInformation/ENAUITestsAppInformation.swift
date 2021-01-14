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
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.aboutNavigation"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.AppInformation.faqNavigation"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.AppInformation.contactNavigation"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.AppInformation.privacyNavigation"].waitForExistence(timeout: 5.0))
		XCTAssert(app.cells["AppStrings.AppInformation.termsNavigation"].waitForExistence(timeout: 5.0))

	}

	func test_0021_AppInformationFlow_about() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.aboutNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.aboutNavigation"].tap()

		XCTAssert(app.staticTexts["AppStrings.AppInformation.aboutTitle"].waitForExistence(timeout: 5.0))
	}

	func test_0022_AppInformationFlow_faq() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.faqNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.faqNavigation"].tap()

		// the following test will fail if device language is not English
		XCTAssert(app.staticTexts["Done"].waitForExistence(timeout: 5.0))
	}

	func test_0023_AppInformationFlow_contact() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.contactNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.contactNavigation"].tap()

		XCTAssert(app.staticTexts["AppStrings.AppInformation.contactTitle"].waitForExistence(timeout: 5.0))
	}

	func test_0024_AppInformationFlow_privacy() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.privacyNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.privacyNavigation"].tap()

		XCTAssert(app.images["AppStrings.AppInformation.privacyImageDescription"].waitForExistence(timeout: 5.0))
	}

	func test_0025_AppInformationFlow_terms() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssert(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))

		app.swipeUp()
		// assert cells
		XCTAssert(app.cells["AppStrings.Home.appInformationCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.appInformationCardTitle"].tap()

		XCTAssert(app.cells["AppStrings.AppInformation.termsNavigation"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.AppInformation.termsNavigation"].tap()

		XCTAssert(app.images["AppStrings.AppInformation.termsImageDescription"].waitForExistence(timeout: 5.0))
	}
}
