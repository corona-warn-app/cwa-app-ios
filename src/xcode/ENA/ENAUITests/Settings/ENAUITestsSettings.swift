//
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_03_Settings: XCTestCase {
	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

	func test_0030_SettingsFlow() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()
		
		XCTAssertTrue(app.cells["AppStrings.Settings.tracingLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.notificationLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.resetLabel"].waitForExistence(timeout: 5.0))
		XCTAssertTrue(app.cells["AppStrings.Settings.Datadonation.description"].waitForExistence(timeout: 5.0))
	}

	func test_0031_SettingsFlow_BackgroundAppRefresh() throws {
		app.launch()
		
		app.swipeUp(velocity: .fast)

		XCTAssertTrue(app.cells["AppStrings.Home.settingsCardTitle"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Home.settingsCardTitle"].tap()
		
		XCTAssertTrue(app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].waitForExistence(timeout: 5.0))
		app.cells["AppStrings.Settings.backgroundAppRefreshLabel"].tap()
		
		XCTAssertTrue(app.images["AppStrings.Settings.backgroundAppRefreshImageDescription"].waitForExistence(timeout: 5.0))
	}
}
