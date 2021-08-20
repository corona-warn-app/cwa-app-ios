////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_OnBehalfCheckinSubmission: CWATestCase {
	
	// MARK: - Setup.
	
	override func setUpWithError() throws {
		try super.setUpWithError()

		continueAfterFailure = false

		app = XCUIApplication()
		setupSnapshot(app)

		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.userNeedsToBeInformedAboutHowRiskDetectionWorks, to: false)
	}
	
	// MARK: - Attributes.
	
	var app: XCUIApplication!
	
	// MARK: - Test cases.

	func testOnBehalfCheckinSubmission() throws {
		// GIVEN
		app.setLaunchArgument(LaunchArguments.infoScreen.traceLocationsInfoScreenShown, to: true)

		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		traceLocationsCardButton.waitAndTap()

		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))

		createTraceLocation(event: "Bäckerei", location: "Innenstadt")

		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))

		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.TraceLocation.Overview.menueButton].waitAndTap()

		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.infoTitle)].exists)

		// tap "In Vertretung warnen" button
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle)].waitAndTap()

		// Wait for info screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.Info.title)].waitForExistence(timeout: .short))

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for trace location selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.title)].waitForExistence(timeout: .short))

		let selectionContinueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(selectionContinueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(selectionContinueButton.isEnabled)

		app.cells[AccessibilityIdentifiers.OnBehalfCheckinSubmission.TraceLocationSelection.selectionCell].firstMatch.waitAndTap()

		// Tap continue
		XCTAssertTrue(selectionContinueButton.isEnabled)
		selectionContinueButton.waitAndTap()

		// Wait for date and time selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.title)].waitForExistence(timeout: .short))

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for tan input screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TANInput.title)].waitForExistence(timeout: .short))

		let continueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(continueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(continueButton.isEnabled)

		// Fill in dummy TAN.
		type(app, text: "qwdzxcsrhe")

		// Tap continue
		XCTAssertTrue(continueButton.isEnabled)
		continueButton.waitAndTap()

		// Wait for thank you screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.ThankYou.title)].waitForExistence(timeout: .short))
	}

	// MARK: - Private

	private func type(_ app: XCUIApplication, text: String) {
		text.forEach {
			app.keyboards.keys[String($0)].waitAndTap()
		}
	}
	
	private func createTraceLocation(event: String, location: String) {
		// add trace location
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitAndTap()
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))

		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitAndTap()
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		descriptionInputField.waitAndTap()
		descriptionInputField.typeText(event)
		locationInputField.waitAndTap()
		locationInputField.typeText(location)

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
	}
	
}
