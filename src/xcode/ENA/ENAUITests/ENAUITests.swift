//
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests: XCTestCase {
	var app: XCUIApplication!

	override func setUp() {
		super.setUp()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchEnvironment["IsOnboarded"] = "NO"
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func navigateThroughOnboarding() throws {
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].tap()
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].tap()
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingContinue"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.Onboarding.onboardingContinue"].tap()
	}

	func test_0000_Generate_Screenshots_For_AppStore() throws {

		let snapshotsActive = true

		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		// ScreenShot_0001: Onboarding screen 1
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: 5.0))
		if snapshotsActive { snapshot("AppStore_0001") }

		// ScreenShot_0002: Homescreen (low risk)
		try navigateThroughOnboarding()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
		if snapshotsActive { snapshot("AppStore_0002") }

		// ScreenShot_0003: Risk view (low risk)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].tap()
		XCTAssertTrue(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5.0))
		if snapshotsActive { snapshot("AppStore_0003") }

		// ScreenShot_0004: Settings > Risk exposure
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: 5.0))
		app.swipeUp(velocity: .slow)
		// ScreenShot_0004: Settings > Risk exposure
		app.swipeUp() // the home screen got loger and for some reason we have to scroll to `tap()`
		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: .extraLong))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()
		XCTAssertTrue(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: .extraLong))
		app.cells["AppStrings.Settings.tracingLabel"].tap()
		XCTAssertTrue(app.images["AppStrings.ExposureNotificationSetting.accLabelEnabled"].waitForExistence(timeout: 5.0))
		if snapshotsActive { snapshot("AppStore_0004") }

		// ScreenShot_0005: Test Options
		// todo: need accessibility for Settings (navigation bar back button)
		XCTAssertTrue(app.navigationBars.buttons.element(boundBy: 0).waitForExistence(timeout: 5.0))
		app.navigationBars.buttons.element(boundBy: 0).tap()
		XCTAssertTrue(app.navigationBars.buttons.element(boundBy: 0).waitForExistence(timeout: 5.0))
		app.navigationBars.buttons.element(boundBy: 0).tap()
		app.swipeDown()
		// todo: need accessibility for Notify and Help
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()
		// todo: need accessibility for Next
		XCTAssertTrue(app.staticTexts["AppStrings.ExposureSubmissionDispatch.description"].waitForExistence(timeout: .medium))

		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitForExistence(timeout: 5.0))
		if snapshotsActive { snapshot("AppStore_0005") }

		// ScreenShot_0007: Share screen
		// todo: need accessibility for Back (navigation bar back button)
		XCTAssertTrue(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: 5.0))
		app.buttons["AppStrings.AccessibilityLabel.close"].tap()
		app.swipeUp()
		XCTAssertTrue(app.cells["AppStrings.Home.infoCardShareTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.infoCardShareTitle"].tap()
		if snapshotsActive { snapshot("AppStore_0007") }

		print("Snapshot.screenshotsDirectory")
		print(Snapshot.screenshotsDirectory?.path ?? "unknown output directory")

	}
	
	func test_0003_Generate_Screenshot_For_AppStore_Statistics() throws {

		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-useMockDataForStatistics", "YES"]) // prevent failing tests for 1.11; use "NO" for 1.12
		app.launch()

		app.swipeUp(velocity: .slow)
		// ScreenShot_0008: Statistics on Home screen
		XCTAssert(app.staticTexts[AccessibilityIdentifiers.Statistics.Infections.title].exists)
		snapshot("AppStore_0008")
	}

	func test_0001_Generate_Screenshots_For_AppStore_Submission() throws {

		let snapshotsActive = true

		app.setPreferredContentSizeCategory(accessibililty: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.negative.stringValue])
		app.launch()

		// ScreenShot_0006: Negative result
		try navigateThroughOnboarding()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: 5.0))
		app.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

		if snapshotsActive { snapshot("AppStore_0006") }
	}

}
