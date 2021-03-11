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
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.faq].exists)

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].exists)
		
		
		// The accessibility identifier for the button looks weird.
		// There is also the accessibility identifier AccessibilityIdentifiers.ErrorReport.privacyNavigation
		//   which looks more appropriate. Please check > A. Vogel
		app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].tap()
		
		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
	}

	func test_0027_AppInformationFlow_ErrorReportsStart() throws {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: .short))

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.saveLocallyButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)
		
		app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].tap()

		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.saveLocallyButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)

	}
	
	private func navigateToErrorReporting() {
		guard let element = UITestHelper.scrollTo(identifier: "AppStrings.Home.appInformationCardTitle", element: app, app: app)
		else {
			XCTFail("Did not found element ID: 'AppStrings.Home.appInformationCardTitle'")
			return
		}
		
		// navigate to App Information
		XCTAssertTrue(element.waitForExistence(timeout: 5.0))
		element.tap()

		// navigate to Error Reporting
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.navigation].waitForExistence(timeout: 5.0))
		app.cells[AccessibilityIdentifiers.ErrorReport.navigation].tap()
	}
}
