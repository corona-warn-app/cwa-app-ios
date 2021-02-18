////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITestsQuickActions: XCTestCase {


	private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
	private var cwaBundleDisplayName = "Corona-Warn" // dynamic app name!
	/// The translated label string as we can't (?) use any identifiers there
	private lazy var newDiaryEntryLabel = XCUIApplication().localized(AppStrings.QuickActions.contactDiaryNewEntry)

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

		let actionButton = springboard.buttons[newDiaryEntryLabel]
		XCTAssertFalse(actionButton.exists, "Shortcuts should not be available on 'fresh' installations which aren't onboarded")
    }

	func testLaunchAfterOnboarding() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launch()

		// On home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))
		// back out
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let actionButton = springboard.buttons[newDiaryEntryLabel]
		XCTAssertTrue(actionButton.waitForExistence(timeout: .short))
		actionButton.tap()
		XCTAssertTrue(app.segmentedControls[AccessibilityIdentifiers.ContactDiary.segmentedControl].waitForExistence(timeout: .short))
	}

	func testShortcutAvailabilityDuringSubmissionFlow() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-ENStatus", ENStatus.active.stringValue])
		app.launchArguments += [UITestingParameters.ExposureSubmission.useMock.rawValue]
		app.launchArguments.append(contentsOf: ["-testResult", TestResult.positive.stringValue])
		app.launch()

		// Open Intro screen.
		XCTAssertTrue(app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .long))
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].tap()

		// in submission flow, that's ok
		XCTAssertTrue(app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitForExistence(timeout: .short))
		// back out
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let actionButton = springboard.buttons[newDiaryEntryLabel]
		XCTAssertFalse(actionButton.exists, "Shortcuts should not be available once the user is in submission flow")
	}

	// MARK: - Install/Uninstall our app

	/// Uninstalling the app manually, if present.
	///
	/// No hacks and `.resolve()` involved!
	private func uninstallCWAppIfPresent() throws {
		let appIcon = springboard.icons[cwaBundleDisplayName]
		guard appIcon.waitForExistence(timeout: .medium) else { return }
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
		XCUIDevice.shared.press(.home)
		return app
	}
}
