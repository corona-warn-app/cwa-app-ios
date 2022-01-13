////
// 🦠 Corona-Warn-App
//

import XCTest
import ExposureNotification

class ENAUITests_11_QuickActions: CWATestCase {

	private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
	private lazy var cwaBundleDisplayName = "Corona-Warn"
	/// The translated label string as we can't (?) use any identifiers there
	private lazy var newDiaryEntryLabel = XCUIApplication().localized(AppStrings.QuickActions.contactDiaryNewEntry)
	private lazy var eventCheckinLabel = XCUIApplication().localized(AppStrings.QuickActions.eventCheckin)

    override func setUpWithError() throws {
		try super.setUpWithError()
        continueAfterFailure = false

		// Clear potentially broken states by pressing the home button
		// Yes kids, your fancy device once had a button to bring you back to the dashboard ;)
		XCUIDevice.shared.press(.home)
    }

	override func tearDownWithError() throws {
		try super.tearDownWithError()
		XCUIDevice.shared.press(.home)
	}

	/// Test shortcut state after a fresh installtation
	///
	/// This test is INTENTIONALLY disabled in the normal test plan as it might affect the execution of other tests
	/// (in the current test/fastlane configuration)
    func testLaunchViaShortcutFromFreshInstall() throws {
		try uninstallCWAppIfPresent()

		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertFalse(appIcon.isHittable)

		// fresh installation
		let app = try installCWApp()
		// validate; onboarding first screen?
		XCTAssertTrue(app.staticTexts["AppStrings.Onboarding.onboardingInfo_togetherAgainstCoronaPage_title"].waitForExistence(timeout: .long))

		// Shortcuts should not be available on 'fresh' installations which aren't onboarded
		try checkAppMenu(expectNewDiaryItem: false, expectEventCheckin: false)
    }

	func testLaunchAfterOnboarding_diaryInfoRequired() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.diaryInfoScreenShown, to: false) // first launch of the contact diary
		app.launch()

		// On home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))

		let quickAction = try checkAppMenu(expectNewDiaryItem: true)
		quickAction.waitAndTap()

		// we expect the info screen
		XCTAssertFalse(app.segmentedControls[AccessibilityIdentifiers.ContactDiary.segmentedControl].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts["AppStrings.ContactDiaryInformation.descriptionTitle"].exists)
	}

	func testLaunchAfterOnboarding_diaryInfoPassed() throws {
		let app = XCUIApplication()
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.diaryInfoScreenShown, to: true) // contact diary info stuff shown and accepted
		app.launch()

		// On home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))
		let quickAction = try checkAppMenu(expectNewDiaryItem: true)
		quickAction.waitAndTap()

		XCTAssertTrue(app.segmentedControls[AccessibilityIdentifiers.ContactDiary.segmentedControl].waitForExistence(timeout: .short))
	}
	

	func testShortcutAvailabilityDuringSubmissionFlow() throws {
		let app = XCUIApplication()
		app.setDefaults()

		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.common.ENStatus, to: ENStatus.active.stringValue)
		app.launch()

		/// Now on Home screen. Go to "Register your test" screen.
		app.cells.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitAndTap()

		/// Now on "Register your Test" screen. Go to "Enter TAN for PCR Test" screen.
		
		app.buttons[AccessibilityIdentifiers.ExposureSubmissionDispatch.tanButtonDescription].waitAndTap()

		/// Now on "Enter TAN" screen. Enter TAN, but not submit it.
		
		let continueButton = app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))


		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertTrue(continueButton.isEnabled)
		
		try checkAppMenu(expectNewDiaryItem: true, expectEventCheckin: true)
		
		/// Submit TAN
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].isEnabled)
		app.buttons[AccessibilityIdentifiers.ExposureSubmission.primaryButton].waitAndTap()
		// remember: TAN tests are ALWAYS positive!

		/// Result Screen
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.ExposureSubmission.secondaryButton].waitForExistence(timeout: .medium))
		try checkAppMenu(expectNewDiaryItem: false, expectEventCheckin: false) // !!! Quick action should be disabled until we leave the submission flow

		// We currently back out of the submission flow. This might be extended in future, feel free to add tests for the following views :)
		app.buttons[AccessibilityIdentifiers.AccessibilityLabel.close].waitAndTap()

		// don't warn
		app.alerts.firstMatch.buttons.element(boundBy: 1).waitAndTap()

		// Back on home screen?
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.submitCardButton].waitForExistence(timeout: .medium))
		try checkAppMenu(expectNewDiaryItem: true, expectEventCheckin: true) // available again?
	}


	/// Checks the state of the quick action menu according to given parameter.
	///
	/// Once we have a 3rd parameter, we should find a better solution than simply adding plain arguments.
	/// - Parameter expectNewDiaryItem: The desired state whether the 'new diary entry; menu item is existing or not.
	/// - Parameter expectEventCheckin: The desired state whether the 'event checkin' menu item is existing or not.
	/// - Throws: All the funny test errors you might encounter when assertions are not met
	private func checkAppMenu(expectNewDiaryItem: Bool, expectEventCheckin: Bool) throws {
		// to dashboard
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let diaryEntryButton = springboard.buttons[newDiaryEntryLabel]
		if expectNewDiaryItem {
			XCTAssertTrue(diaryEntryButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertFalse(diaryEntryButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}

		let eventCheckinButton = springboard.buttons[eventCheckinLabel]
		if expectEventCheckin {
			XCTAssertTrue(eventCheckinButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertFalse(eventCheckinButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}

		// discard menu and return to app w/o quick action
		XCUIDevice.shared.press(.home)
		// reference to `appIcon` fails for unknown reasons
		springboard.icons[cwaBundleDisplayName].waitAndTap()
	}
	
	@discardableResult
	private func checkAppMenu(expectNewDiaryItem: Bool) throws -> XCUIElement {
		// to dashboard
		XCUIDevice.shared.press(.home)

		// check app menu
		let appIcon = try XCTUnwrap(springboard.icons[cwaBundleDisplayName])
		XCTAssertTrue(appIcon.waitForExistence(timeout: .short))
		if !appIcon.isHittable {
			springboard.swipeLeft()
		}
		XCTAssertTrue(appIcon.isHittable)
		appIcon.press(forDuration: 1.5)

		let diaryEntryButton = springboard.buttons[newDiaryEntryLabel]
		if expectNewDiaryItem {
			XCTAssertNoThrow(diaryEntryButton.exists, "Shortcuts should be available in this state of the submission flow")
		} else {
			XCTAssertThrowsError(diaryEntryButton.exists, "Shortcuts should not be available once the user is in submission flow")
		}
		return diaryEntryButton
	}

	// MARK: - Install/Uninstall our app

	/// Uninstalling the app manually, if present.
	private func uninstallCWAppIfPresent() throws {
		let appIcon = springboard.icons[cwaBundleDisplayName]
		guard appIcon.waitForExistence(timeout: .medium) else { return }
		while !appIcon.isHittable {
			springboard.swipeLeft()
		}
		appIcon.press(forDuration: 1.5)

		// 1. action menu
		springboard.collectionViews.firstMatch.buttons.lastMatch.waitAndTap()

		// 2. `„Corona-Warn“ entfernen?` alert
		let firstAlert = springboard.alerts.firstMatch
		firstAlert.buttons.firstMatch.waitAndTap()

		// 3. `„Corona-Warn“ löschen?` alert
		let finalAlert = springboard.alerts.firstMatch
		finalAlert.buttons.lastMatch.waitAndTap()
	}

	/// Installs the host app and terminates it right after launch to simulate a (nearly) 'fresh' installation
	///
	/// Because the app still starts shortly, our AppDelegate code runs. Keep this in mind if you encounter some edge cases!
	private func installCWApp() throws -> XCUIApplication {
		let app = XCUIApplication()
		app.launch()
		XCTAssertEqual(app.state, XCUIApplication.State.runningForeground)
		XCUIDevice.shared.press(.home)
		return app
	}
}
