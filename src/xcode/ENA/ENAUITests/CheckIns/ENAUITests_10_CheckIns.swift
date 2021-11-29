////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_10_CheckIns: CWATestCase {
	
	var app: XCUIApplication!
	var screenshotCounter = 0
	let prefix = "event_checkin_"
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.setLaunchArgument(LaunchArguments.onboarding.isOnboarded, to: true)
		app.setLaunchArgument(LaunchArguments.onboarding.setCurrentOnboardingVersion, to: true)
	}
	
	func testCheckinInfoScreen_navigate_to_dataPrivacy() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: false)
		app.launch()
			
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.acknowledgementTitle].exists)
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].exists)
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionTitle].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionSubHeadline].exists)
		
		// find data privacy cell (last cell) and tap it
		guard let lastCell = app.tables.firstMatch.cells.allElementsBoundByIndex.last,
			  lastCell.identifier == AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle else {
			XCTFail("Could not find last table view cell")
			return
		}
		
		let maxTries = 10
		var currentTry = 0
		while lastCell.isHittable == false && currentTry < maxTries {
			app.swipeUp()
			currentTry += 1
		}
		lastCell.waitAndTap()
		
		XCTAssertTrue(app.images[AccessibilityIdentifiers.AppInformation.privacyImageDescription].waitForExistence(timeout: .extraLong))
	}
	
	func testCheckinInfoScreen_confirmConsent() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: false)
		app.launch()
		
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()
		
		// Confirm consent
		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].waitAndTap()
				
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.Overview.title)].waitForExistence(timeout: .short))
	}

	func test_RegisterCertificateFromCheckinTabWithInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: false)
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		certificateButton.waitAndTap()

		/// Certificate Info Screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.HealthCertificate.Info.title)].waitForExistence(timeout: .short))

		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		/// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_RegisterCertificateFromCheckinTabWithoutInfoScreen() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.healthCertificateInfoScreenShown, to: true)
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let certificateButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeHC1])
		certificateButton.waitAndTap()

		/// Certificate Screen
		let headlineCell = try XCTUnwrap(app.cells[AccessibilityIdentifiers.HealthCertificate.Certificate.headline])
		XCTAssertTrue(headlineCell.waitForExistence(timeout: .short))
	}

	func test_RegisterCoronaTestFromCheckinTab() throws {
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: true)
		app.launch()

		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()

		/// Tap Scan Button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitAndTap()

		/// Simulator only Alert will open where you can choose what the QRScanner should scan
		let pcrButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakePCR])
		pcrButton.waitAndTap()

		/// Exposure Submission QR Info Screen
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.ExposureSubmissionQRInfo.title)].waitForExistence(timeout: .short))
	}
	
	// MARK: - Screenshots

	func test_screenshot_WHEN_scan_QRCode_THEN_checkin_and_checkout() throws {
		// GIVEN
		app.setLaunchArgument(LaunchArguments.infoScreen.checkinInfoScreenShown, to: false)
		app.launch()
		
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.TabBar.checkin].waitAndTap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.acknowledgementTitle].exists)
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].exists)
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionTitle].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionSubHeadline].exists)
		
		screenshotCounter = 0
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinInfoScreen")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinInfoScreen")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinInfoScreen")
		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].waitAndTap()
		
		// WHEN
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitForExistence(timeout: .short))
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins_emptyList")
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitAndTap()
		
		// Simulator only Alert will open where you can choose what the QRScanner should scan, we want the Event here.
		let eventButton = try XCTUnwrap(app.buttons[AccessibilityIdentifiers.UniversalQRScanner.fakeEvent])
		eventButton.waitAndTap()
		
		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].waitAndTap()
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.checkinFor].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts["Bistro & Café am Neuen Markt"].exists)
		XCTAssertTrue(app.staticTexts["Hamburg, Schulstraße 4"].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.title.foodService)].exists)
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins_checkin")
		// check in
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].waitAndTap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins")
		
		// check out and clean up; take screenshots
		myCheckins_checkout()
	}
	
	// MARK: - Private
	
	private func myCheckins_checkout() {
		
		let initialNumberOfCells = app.cells.count
		
		// iterate over all event cells and search for the checkout button
		let query = app.cells.buttons
		let n = query.count
		XCTAssertTrue(n > 1)
		var numberOfCheckouts = 0
		for i in 0...(n - 1) {
			if query.element(boundBy: i).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton {
				numberOfCheckouts = numberOfCheckouts.inc()
			}
		}
		XCTAssertTrue(numberOfCheckouts == 1) // assumption: one cell has a checkout button
		
		// tap checkout button
		XCTAssertTrue(query.element(boundBy: 1).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton)
		query.element(boundBy: 1).waitAndTap()
		var screenshotCounter = 3
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinList")
		
		// tap the event, verify the detail screen
		XCTAssertTrue(initialNumberOfCells == app.cells.count) // assumption: number of cells has not changed
		query.element(boundBy: 1).waitAndTap()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetails")
		
		let staticTexts = app.cells.staticTexts
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.typeLabel).waitForExistence(timeout: .short))
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationTypeLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationDescriptionLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationAddressLabel).exists)
		XCTAssertTrue(app.staticTexts["Bistro & Café am Neuen Markt"].exists)
		XCTAssertTrue(app.staticTexts["Hamburg, Schulstraße 4"].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.title.foodService)].exists)

		// checkin time details
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.typeLabel].exists)
		
		for i in 0...(app.staticTexts.count - 1) {
			if app.staticTexts.element(boundBy: i).identifier == AccessibilityIdentifiers.Checkin.Details.typeLabel {
				app.staticTexts.element(boundBy: i).waitAndTap()
				break
			}
		}
				
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetailsTime")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetailsTime")
		
		// tap "Speichern" to go back to overview
		let buttons = app.buttons
		buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).waitAndTap()
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinList")
		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.Checkin.Overview.menueButton].waitAndTap()
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinActionSheet")
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].waitAndTap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDeleteAll")
		// button "Alle entfernen"
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitAndTap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDeleteAllAlert")
		// Alert: tap "Entfernen"
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteOneAlert.confirmButtonTitle)].waitAndTap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
	}
}
