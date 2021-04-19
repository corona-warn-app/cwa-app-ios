////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_10_CheckIns: XCTestCase {
	
	var app: XCUIApplication!
	var screenshotCounter = 0
	let prefix = "event_checkin_"
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		
	}
	
	func test_WHEN_scan_QRCode_THEN_checkin_and_checkout() {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "NO"])
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
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
		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].tap()
		
		// WHEN
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].waitForExistence(timeout: .short))
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins_emptyList")
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.scanButtonTitle)].tap()
		
		// THEN
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.saveToDiary].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.automaticCheckout].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.checkinFor].exists)
		XCTAssertTrue(app.staticTexts["Supermarkt"].exists)
		XCTAssertTrue(app.staticTexts["Walldorf"].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.title.retail)].exists)
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins_checkin")
		// check in
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.TraceLocation.Details.checkInButton].tap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_mycheckins")
		
		// check out and clean up; take screenshots
		myCheckins_checkout()
	}
	
	func testCheckinInfoScreen_navigate_to_dataPrivacy() throws {
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "NO"])
		app.launch()
		
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		
		// Navigate to CheckIn
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.acknowledgementTitle].exists)
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].exists)
		
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionTitle].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Information.descriptionSubHeadline].exists)
				
		// Navigate to Data Privacy
		if let target = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle, element: app, app: app) {
			target.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Checkin.Information.dataPrivacyTitle)")
		}
		
		XCTAssertTrue(app.staticTexts["AppStrings.AppInformation.privacyTitle"].waitForExistence(timeout: .short))
	}
	
	func testCheckinInfoScreen_confirmConsent() throws {
		app.launchArguments.append(contentsOf: ["-checkinInfoScreenShown", "NO"])
		app.launch()
		
		// Navigate to CheckIn
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Tabbar.checkin].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.Tabbar.checkin].tap()
		
		// Confirm consent
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.Checkin.Information.primaryButton].tap()
				
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.Checkins.Overview.title)].waitForExistence(timeout: .short))
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
		query.element(boundBy: 1).tap()
		var screenshotCounter = 3
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinList")
		
		// tap the event, verify the detail screen
		XCTAssertTrue(initialNumberOfCells == app.cells.count) // assumption: number of cells has not changed
		query.element(boundBy: 1).tap()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetails")
		
		let staticTexts = app.cells.staticTexts
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.typeLabel).waitForExistence(timeout: .short))
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationTypeLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationDescriptionLabel).exists)
		XCTAssertTrue(staticTexts.element(matching: .staticText, identifier: AccessibilityIdentifiers.Checkin.Details.traceLocationAddressLabel).exists)
		XCTAssertTrue(app.staticTexts["Supermarkt"].exists)
		XCTAssertTrue(app.staticTexts["Walldorf"].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.title.retail)].exists)

		// checkin time details
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.Checkin.Details.typeLabel].exists)
		
		for i in 0...(app.staticTexts.count - 1) {
			if app.staticTexts.element(boundBy: i).identifier == AccessibilityIdentifiers.Checkin.Details.typeLabel {
				app.staticTexts.element(boundBy: i).tap()
				break
			}
		}
				
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetailsTime")
		app.swipeUp()
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDetailsTime")
		
		// tap "Speichern" to go back to overview
		let buttons = app.buttons
		XCTAssertTrue(buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).exists)
		buttons.element(matching: .button, identifier: AccessibilityIdentifiers.General.primaryFooterButton).tap()
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinList")
		// tap the "more" button
		app.navigationBars.buttons[AccessibilityIdentifiers.Checkin.Overview.menueButton].tap()
		
		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinActionSheet")
		// verify the buttons
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.infoTitle)].exists)
		
		// tap "Edit" button
		app.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.ActionSheet.editTitle)].tap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDeleteAll")
		// button "Alle entfernen"
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
		app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()

		snapshot(prefix + (String(format: "%03d", (screenshotCounter.inc() ))) + "_checkinDeleteAllAlert")
		// Alert: tap "Entfernen"
		XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteAllAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		app.alerts.buttons[AccessibilityLabels.localized(AppStrings.Checkins.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		
		XCTAssertTrue(app.cells.count == 1) // assumption: only one cell remains
	}
}
