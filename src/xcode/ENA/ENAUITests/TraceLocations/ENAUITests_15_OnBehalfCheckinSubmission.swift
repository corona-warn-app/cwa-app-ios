////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_15_OnBehalfCheckinSubmission: CWATestCase {
	
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

	func test_screenshot_OnBehalfCheckinSubmissionWithExistingTraceLocation() throws {
		// GIVEN
		app.setLaunchArgument(LaunchArguments.infoScreen.traceLocationsInfoScreenShown, to: true)

		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		traceLocationsCardButton.waitAndTap()

		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))

		createTraceLocation(event: "Konzert", location: "Konzerthalle Innenstadt")

		// Wait for trace locations screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))

		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.TraceLocation.Overview.menueButton].waitAndTap()

		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle)].exists)

		// tap "In Vertretung warnen" button
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle)].waitAndTap()

		// Wait for info screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.Info.title)].waitForExistence(timeout: .short))

		snapshot("onbehalfwarning_info")

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for trace location selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.title)].waitForExistence(timeout: .short))

		// Check that button is disabled
		let selectionContinueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(selectionContinueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(selectionContinueButton.isEnabled)

		app.cells[AccessibilityIdentifiers.OnBehalfCheckinSubmission.TraceLocationSelection.selectionCell].firstMatch.waitAndTap()

		snapshot("onbehalfwarning_location_selection")

		// Tap continue
		XCTAssertTrue(selectionContinueButton.isEnabled)
		selectionContinueButton.waitAndTap()

		// Wait for date and time selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.title)].waitForExistence(timeout: .short))

		app.cells[AccessibilityIdentifiers.OnBehalfCheckinSubmission.DateTimeSelection.durationCell].waitAndTap(.extraLong)

		snapshot("onbehalfwarning_date_time_selection")

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for tan input screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TANInput.title)].waitForExistence(timeout: .short))

		let tanContinueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(tanContinueButton.waitForExistence(timeout: .medium))
		
		snapshot("onbehalfwarning_tan")

		// Tap continue
		XCTAssertTrue(tanContinueButton.isEnabled)
		tanContinueButton.waitAndTap()

		// Wait for thank you screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.ThankYou.title)].waitForExistence(timeout: .short))

		snapshot("onbehalfwarning_thank_you")
	}

	func testOnBehalfCheckinSubmissionWithQRCodeScan() throws {
		// GIVEN
		app.setLaunchArgument(LaunchArguments.infoScreen.traceLocationsInfoScreenShown, to: true)

		// WHEN
		app.launch()

		let traceLocationsCardButton = app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton]
		traceLocationsCardButton.waitAndTap()

		// Wait for trace locations screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))

		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.TraceLocation.Overview.menueButton].waitAndTap()

		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle)].exists)

		// tap "In Vertretung warnen" button
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle)].waitAndTap()

		// Wait for info screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.Info.title)].waitForExistence(timeout: .short))

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for trace location selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.title)].waitForExistence(timeout: .short))

		// Check that button is disabled
		let selectionContinueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(selectionContinueButton.waitForExistence(timeout: .medium))
		XCTAssertFalse(selectionContinueButton.isEnabled)

		// Check that empty state view is there
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.EmptyState.title)].waitForExistence(timeout: .short))

		app.buttons[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.scanButtonTitle)].waitAndTap()

		// Simulator only Alert will open where you can choose what the QRScanner should scan, we want to select an event code here.
		let eventButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeEvent])
		eventButton.waitAndTap()

		// Wait for date and time selection screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.title)].waitForExistence(timeout: .short))

		// Tap continue
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		// Wait for tan input screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.OnBehalfCheckinSubmission.TANInput.title)].waitForExistence(timeout: .short))

		let tanContinueButton = app.buttons[AccessibilityIdentifiers.General.primaryFooterButton]
		XCTAssertTrue(tanContinueButton.waitForExistence(timeout: .medium))

		// Tap continue
		XCTAssertTrue(tanContinueButton.isEnabled)
		tanContinueButton.waitAndTap()

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
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.temporary.subtitle.culturalEvent)].waitForExistence(timeout: .short))

		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.temporary.subtitle.culturalEvent)].waitAndTap()
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		descriptionInputField.waitAndTap()
		descriptionInputField.typeText(event)
		locationInputField.waitAndTap()
		locationInputField.typeText(location)

		app.buttons["AppStrings.ExposureSubmission.primaryButton"].waitAndTap()
	}
	
}
