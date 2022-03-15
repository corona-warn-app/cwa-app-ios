//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_Settings: CWATestCase {
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

	func test_0030_SettingsFlow() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		settingsLabel.waitAndTap()

		XCTAssertTrue(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.notificationLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.resetLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.Datadonation.description"].waitForExistence(timeout: 5.0))
	}

	func test_0031_SettingsFlow_BackgroundAppRefresh() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		settingsLabel.waitAndTap()

		app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitAndTap()
		
		XCTAssertTrue(app.images["AppStrings.Settings.backgroundAppRefreshImageDescription"].waitForExistence(timeout: 5.0))
	}
	
	func test_SettingsNotificationsOn() throws {
		app.setLaunchArgument(LaunchArguments.notifications.isNotificationsEnabled, to: true)
		app.launch()
				
		// Open settings
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		settingsLabel.waitAndTap()

		// Open Notifications
		app.cells[AccessibilityIdentifiers.Settings.notificationLabel].waitAndTap()
		
		// Check if we are on notifications screen - ON
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOn].waitForExistence(timeout: .medium))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.notificationsOn].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletDescOn].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint1].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint2].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletPoint3].waitForExistence(timeout: .short))
		XCTAssertTrue(app.textViews[AccessibilityIdentifiers.NotificationSettings.bulletDesc2].waitForExistence(timeout: .short))
		
		app.swipeUp()
		
		// Jump to system settings.
		app.buttons[AccessibilityIdentifiers.NotificationSettings.openSystemSettings].waitAndTap()
		
		// Check if URL that would get opened is 'app-settings:'
		XCTAssertTrue(app.alerts.firstMatch.staticTexts["app-settings:"].waitForExistence(timeout: .short))
	}
	
	func test_SettingsNotificationsOff() throws {
		app.setLaunchArgument(LaunchArguments.notifications.isNotificationsEnabled, to: false)
		app.launch()
				
		// Open settings
		let moreCell = app.cells[AccessibilityIdentifiers.Home.MoreInfoCell.moreCell]
		let settingsLabel = moreCell.buttons[AccessibilityIdentifiers.Home.MoreInfoCell.settingsLabel]
		settingsLabel.waitAndTap()

		// Open Notifications
		app.cells[AccessibilityIdentifiers.Settings.notificationLabel].waitAndTap()
		
		// Check if we are on notifications screen - OFF
		XCTAssertTrue(app.tables.images[AccessibilityIdentifiers.NotificationSettings.DeltaOnboarding.imageOff].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.notificationsOff].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.NotificationSettings.bulletDescOff].waitForExistence(timeout: .short))
		
		// Jump to system settings.
		app.buttons[AccessibilityIdentifiers.NotificationSettings.openSystemSettings].waitAndTap()
		
		// Check if URL that would get opened is 'app-settings:'
		XCTAssertTrue(app.alerts.firstMatch.staticTexts["app-settings:"].waitForExistence(timeout: .short))
	}
}
