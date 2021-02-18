////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITestsQuickActions: XCTestCase {


	private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
	private var cwaBundleDisplayName = "Corona-Warn" // dynamic app name!

    override func setUpWithError() throws {
        continueAfterFailure = false

		// Clear potentially broken states by pressing the home button
		// Yes kids, your fancy device once had a button to bring you back to the dashboard ;)
		XCUIDevice.shared.press(.home)
    }

	override func tearDownWithError() throws {
		XCUIDevice.shared.press(.home)
	}

    func testLaunchViaShortcutFromFreshInstall() throws {
		try uninstallCWAppIfPresent()

		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertFalse(appIcon.isHittable)

		// fresh installation
		let app = try installCWApp()
		// validate; onboarding first screen?
		XCTAssertTrue(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: .long))
		XCUIDevice.shared.press(.home)

		// Ok, now the real test.
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let actionButton = springboard.buttons[AppStrings.QuickActions.contactDiaryNewEntry]
		XCTAssertFalse(actionButton.exists, "Shortcuts should not be available on 'fresh' installations which aren't onboarded")
    }

	// MARK: - Install/Uninstall our app

	/// Uninstalling the app manually, if present.
	///
	/// No hacks and `.resolve()` involved!
	private func uninstallCWAppIfPresent() throws {
		let appIcon = springboard.icons[cwaBundleDisplayName]
		guard appIcon.exists else { return }
		while !appIcon.isHittable {
			springboard.swipeLeft()
		}
		appIcon.press(forDuration: 1.5)

		// 1. action menu
		springboard.collectionViews.firstMatch.buttons.lastMatch.tap()

		// 2. `„Corona-Warn“ entfernen?` alert
		let firstAlert = springboard.alerts.firstMatch
		XCTAssertTrue(firstAlert.waitForExistence(timeout: .short))
		firstAlert.buttons.firstMatch.tap()

		// 3. `„Corona-Warn“ löschen?` alert
		let finalAlert = springboard.alerts.firstMatch
		XCTAssertTrue(finalAlert.waitForExistence(timeout: .short))
		finalAlert.buttons.lastMatch.tap()
	}

	/// Installs the host app and terminates it right after launch to simulate a (nearly) 'fresh' installation
	///
	/// Because the app still starts shortly, our AppDelegate code runs. Keep this in mind if you encounter some edge cases!
	private func installCWApp() throws -> XCUIApplication {
		let app = XCUIApplication()
		app.activate()
		//app.terminate()
		XCUIDevice.shared.press(.home)
		return app
	}
}
