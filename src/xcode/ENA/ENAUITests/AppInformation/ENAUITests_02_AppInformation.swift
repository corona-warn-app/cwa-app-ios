//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_02_AppInformation: CWATestCase {
	var app: XCUIApplication!

	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}

	func test_0020_AppInformationFlow() throws {
		app.launch()
		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.aboutNavigation].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.faqNavigation].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.contactNavigation].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.privacyNavigation].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.AppInformation.termsNavigation].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.navigation].waitForExistence(timeout: .medium))
	}

	func test_0021_AppInformationFlow_about() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		app.cells["AppStrings.AppInformation.aboutNavigation"].waitAndTap()

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.aboutTitle"].waitForExistence(timeout: .medium))
	}

	func test_0022_AppInformationFlow_faq() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		XCTAssertTrue(app.state == .runningForeground)
		app.cells["AppStrings.AppInformation.faqNavigation"].waitAndTap()
		
		// Check if URL that would get opened is 'https://www.coronawarn.app/de/faq/'
		XCTAssertTrue(app.alerts.firstMatch.staticTexts["https://www.coronawarn.app/de/faq/"].waitForExistence(timeout: .short))
	}

	func test_0023_AppInformationFlow_contact() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		app.cells["AppStrings.AppInformation.contactNavigation"].waitAndTap()

		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.contactTitle"].waitForExistence(timeout: .medium))
	}

	func test_0024_AppInformationFlow_privacy() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .long))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		app.cells["AppStrings.AppInformation.privacyNavigation"].waitAndTap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.privacyImageDescription"].waitForExistence(timeout: .long))

		XCTAssertTrue(app.webViews[AccessibilityIdentifiers.General.webView].waitForExistence(timeout: .long))
		let webView = app.webViews[AccessibilityIdentifiers.General.webView]
		let firstLink = webView.links.firstMatch
		firstLink.waitAndTap(.long)
	}

	func test_0025_AppInformationFlow_terms() throws {
		app.launch()

		// only run if onboarding screen is present
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))

		// assert cells
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		app.cells["AppStrings.AppInformation.termsNavigation"].waitAndTap()

		XCTAssertTrue(app.images["AppStrings.AppInformation.termsImageDescription"].waitForExistence(timeout: .medium))
	}
	
	func test_0026a_AppInformationFlow_ErrorReportsShouldBeActiveForDebugAsDefault() throws {
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)
	}
	
	func test_0026_AppInformationFlow_ErrorReports() throws {
		app.setLaunchArgument(LaunchArguments.errorReport.elsLogActive, to: false)
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()

		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.faq].exists)

		XCTAssertTrue(app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].exists)
		
		
		// The accessibility identifier for the button looks weird.
		// There is also the accessibility identifier AccessibilityIdentifiers.ErrorReport.privacyNavigation
		//   which looks more appropriate. Please check > A. Vogel
		app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].waitAndTap()
		
		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
	}

	func test_0027_AppInformationFlow_ErrorReportsStart() throws {
		app.setLaunchArgument(LaunchArguments.errorReport.elsLogActive, to: false)
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.saveLocallyButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].exists)

		app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].waitAndTap()
		
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.saveLocallyButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].exists)
		
		app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].waitAndTap()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.saveLocallyButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.stopAndDeleteButton].exists)
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].exists)
	}
	
	func test_0028_AppInformationFlow_PrivacyScreen() throws {
		app.setLaunchArgument(LaunchArguments.errorReport.elsLogActive, to: false)
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.topBody].waitForExistence(timeout: .short))
		app.cells[AccessibilityIdentifiers.ErrorReport.privacyInformation].waitAndTap()
		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .short))

	}
	
	func test_0029_AppInformationFlow_ConfirmationScreen_ErrorReportDetailScreen() throws {
		app.setLaunchArgument(LaunchArguments.errorReport.elsLogActive, to: false)
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		app.buttons[AccessibilityIdentifiers.ErrorReport.startButton].waitAndTap()
		app.buttons[AccessibilityIdentifiers.ErrorReport.sendReportButton].waitAndTap()
		
		app.cells[AccessibilityIdentifiers.ErrorReport.sendReportsDetails].waitAndTap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.detailedInformationTitle].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.detailedInformationSubHeadline].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.detailedInformationContent2].exists)
	}
	
	func test_0030_AppInformationFlow_ConfirmationScreen_HistoryScreen() throws {
		app.setLaunchArgument(LaunchArguments.errorReport.elsLogActive, to: false)
		app.setLaunchArgument(LaunchArguments.errorReport.elsCreateFakeHistory, to: true)
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .short))
		navigateToErrorReporting()
		
		// Test Navigation to History
		app.cells[AccessibilityIdentifiers.ErrorReport.historyNavigation].waitAndTap()
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.ErrorReport.historyTitle].exists)
	}
	
	private func navigateToErrorReporting() {
		// navigate to App Information
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let appInformationLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.appInformationLabel]
		appInformationLabel.waitAndTap()

		// navigate to Error Reporting
		app.cells[AccessibilityIdentifiers.ErrorReport.navigation].waitAndTap()
	}
}
