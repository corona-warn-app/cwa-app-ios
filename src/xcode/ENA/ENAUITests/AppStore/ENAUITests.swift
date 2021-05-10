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
		app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitAndTap()
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		app.buttons["AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_button"].waitAndTap()
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		app.buttons["AppStrings.Onboarding.onboardingContinue"].waitAndTap()
		app.buttons["General.primaryFooterButton"].waitAndTap()
	}

	// MARK: - Screenshots

	func test_0000_Generate_Screenshots_For_AppStore() throws {

		let snapshotsActive = true

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launch()

		// ScreenShot_0001: Onboarding screen 1
		XCTAssertTrue(app.buttons["AppStrings.Onboarding.onboardingLetsGo"].waitForExistence(timeout: .medium))
		if snapshotsActive { snapshot("AppStore_0001") }

		// ScreenShot_0002: Homescreen (low risk)
		try navigateThroughOnboarding()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))
		if snapshotsActive { snapshot("AppStore_0002") }

		// ScreenShot_0003: Risk view (low risk)
		app.buttons[AccessibilityIdentifiers.Home.RiskTableViewCell.topContainer].waitAndTap()
		XCTAssertTrue(app.buttons["AppStrings.AccessibilityLabel.close"].waitForExistence(timeout: .medium))
		if snapshotsActive { snapshot("AppStore_0003") }

		// ScreenShot_0004: Settings > Risk exposure
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.rightBarButtonDescription].waitForExistence(timeout: .medium))
		app.swipeUp(velocity: .slow)
		// ScreenShot_0004: Settings > Risk exposure
		app.swipeUp() // the home screen got loger and for some reason we have to scroll to `tap()`
		app.cells["AppStrings.Home.settingsCardTitle"].waitAndTap(.extraLong)
		app.cells["AppStrings.Settings.tracingLabel"].waitAndTap(.extraLong)
		XCTAssertTrue(app.images["AppStrings.ExposureNotificationSetting.accLabelEnabled"].waitForExistence(timeout: .medium))
		if snapshotsActive { snapshot("AppStore_0004") }

		// ScreenShot_0005: Test Options
		// todo: need accessibility for Settings (navigation bar back button)
		app.navigationBars.buttons.element(boundBy: 0).waitAndTap()
		app.navigationBars.buttons.element(boundBy: 0).waitAndTap()
		app.swipeDown()
		// todo: need accessibility for Notify and Help
		app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmissionDispatch.qrCodeButtonDescription"].waitForExistence(timeout: .medium))
		if snapshotsActive { snapshot("AppStore_0005") }

		// ScreenShot_0007: Share screen
		// todo: need accessibility for Back (navigation bar back button)
		app.buttons["AppStrings.AccessibilityLabel.close"].waitAndTap()
		app.swipeUp()
		app.cells["AppStrings.Home.infoCardShareTitle"].waitAndTap()
		if snapshotsActive { snapshot("AppStore_0007") }

		print("Snapshot.screenshotsDirectory")
		print(Snapshot.screenshotsDirectory?.path ?? "unknown output directory")

	}
	
	func test_0001_Generate_Screenshots_For_AppStore_Submission() throws {

		let snapshotsActive = true

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "NO"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-pcrTestResult", TestResult.negative.stringValue])
		app.launch()

		// ScreenShot_0006: Negative result
		try navigateThroughOnboarding()
		app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		if snapshotsActive { snapshot("AppStore_0006") }
	}

	func test_0002_Generate_Screenshot_For_AppStore_Statistics() throws {

		app.setPreferredContentSizeCategory(accessibility: .normal, size: .M)
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments.append(contentsOf: ["-useMockDataForStatistics", "YES"]) // prevent failing tests for 1.11; use "NO" for 1.12
		app.launch()

		app.swipeUp(velocity: .slow)
		// ScreenShot_0008: Statistics on Home screen
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Statistics.Infections.title].exists)
		snapshot("AppStore_0008")
	}

}
