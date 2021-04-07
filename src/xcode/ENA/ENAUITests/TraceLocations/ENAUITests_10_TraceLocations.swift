////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_10_TraceLocations: XCTestCase {
	
	// MARK: - Setup.
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
		app.launchArguments.append(contentsOf: ["-userNeedsToBeInformedAboutHowRiskDetectionWorks", "NO"])
	}
	
	// MARK: - Attributes.
	
	var app: XCUIApplication!
	
	// MARK: - Test cases.
	
	func testTraceLocationsHomeCard() throws {
		// GIVEN
		
		// WHEN
		app.launch()
		
		// THEN
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
	}
	
	func testTrace_navigate_to_InformationScreen_for_the_first_time() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "NO"])
		
		// WHEN
		app.launch()
		// Swipe up until it is visible
		
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		// THEN
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.images[AccessibilityIdentifiers.TraceLocation.imageDescription].exists)
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}
	
	func testTrace_navigate_to_InformationScreen_for_the_second_time() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		// THEN
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}
	
	func test_CreateAndDelete_one_traceLocation() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Mittagessen"
		let location = "Kantine"
		createTraceLocation(event: event, location: location)
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event].exists)
		XCTAssertTrue(app.staticTexts[location].exists)

		removeTraceLocation(event: event)

		XCTAssertFalse(app.staticTexts[event].exists)
		XCTAssertFalse(app.staticTexts[location].exists)
	}

	func test_CreateAndDelete_two_traceLocations() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event1 = "Daily Scrum"
		let location1 = "Office"
		createTraceLocation(event: event1, location: location1)

		let event2 = "Sprint Planning"
		let location2 = "Walldorf"
		createTraceLocation(event: event2, location: location2)

		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event1].exists)
		XCTAssertTrue(app.staticTexts[location1].exists)
		XCTAssertTrue(app.staticTexts[event2].exists)
		XCTAssertTrue(app.staticTexts[location2].exists)

		removeAllTraceLocations()

		XCTAssertFalse(app.staticTexts[event1].exists)
		XCTAssertFalse(app.staticTexts[event2].exists)
	}
	
	func test_WHEN_tapCreateQRCode_THEN_traceLocation_input_screen_is_displayed() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		// add trace location
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()

		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder].exists)
		XCTAssertTrue(app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder].exists)
		
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthTitleLabel].exists)
		XCTAssertFalse(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.temporaryDefaultLengthFootnoteLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthTitleLabel].exists)
		XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.TraceLocation.Configuration.permanentDefaultLengthFootnoteLabel].exists)
		
	}

	func test_displayDetailsOfTraceLocation() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Mittagessen"
		let location = "Kantine"
		createTraceLocation(event: event, location: location)
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event].exists)
		XCTAssertTrue(app.staticTexts[location].exists)

		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].tap()
		
		XCTAssertTrue(app.buttons["IconCloseContrastButton"].exists)
		app.buttons["IconCloseContrastButton"].tap()

		removeTraceLocation(event: event)

		XCTAssertFalse(app.staticTexts[event].exists)
		XCTAssertFalse(app.staticTexts[location].exists)
	}
	
	func test_checkinTraceLocation() throws {
		// GIVEN
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		
		// WHEN
		app.launch()
		if let button = UITestHelper.scrollTo(identifier: AccessibilityIdentifiers.Home.traceLocationsCardButton, element: app, app: app) {
			button.tap()
		} else {
			XCTFail("Can't find element \(AccessibilityIdentifiers.Home.traceLocationsCardButton)")
		}
		
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].waitForExistence(timeout: .short))
		
		let event = "Mittagessen"
		let location = "Kantine"
		createTraceLocation(event: event, location: location)
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.title)].waitForExistence(timeout: .short))
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].exists)
		XCTAssertTrue(app.staticTexts[event].exists)
		XCTAssertTrue(app.staticTexts[location].exists)

		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.selfCheckinButtonTitle)].tap()
		
		XCTAssertTrue(app.buttons["Einchecken"].exists)
		app.buttons["Einchecken"].tap()

		removeTraceLocation(event: event)

		XCTAssertFalse(app.staticTexts[event].exists)
		XCTAssertFalse(app.staticTexts[location].exists)
	}

	func createTraceLocation(event: String, location: String) {
		// add trace location
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.addButtonTitle)].tap()
		
		XCTAssertTrue(app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].waitForExistence(timeout: .short))
		app.staticTexts[AccessibilityLabels.localized(AppStrings.TraceLocations.permanent.subtitle.workplace)].tap()
		
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		descriptionInputField.tap()
		descriptionInputField.typeText(event)
		locationInputField.tap()
		locationInputField.typeText(location)
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
	}

	func removeTraceLocation(event: String) {
		app.staticTexts[event].swipeLeft()
		XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
		
		// tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
		// Alert: tap "Löschen"
		app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
	}
	
	func removeAllTraceLocations() {
		let query = app.buttons
		let n = query.count
		
		if n > 0 {
			for i in 0...(n - 1) {
				if query.element(boundBy: i).identifier == AccessibilityIdentifiers.TraceLocation.Configuration.eventTableViewCellButton {
					query.element(boundBy: i).swipeLeft()
					XCTAssertTrue(app.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
					// tap "Alle entfernen"
					XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
					app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
					// Alert: tap "Löschen"
					XCTAssertTrue(app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].waitForExistence(timeout: .short))
					app.alerts.buttons[AccessibilityLabels.localized(AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle)].tap()
					return // all QR codes have been deleted
				}
			}
		}
	}
	
	/*
	func test_screenshot_traceLocation_print_flow() throws {
	app.launch()
	
	// check if the tracelocation card exists
	XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].waitForExistence(timeout: .short))
	
	// navigate to tracelocation overview
	app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()
	
	// take snapshot
	snapshot("tracelocation_overview")
	
	// navigate to tracelocation detail view for second item
	app.tables[AccessibilityIdentifiers.TraceLocation.Overview.tableView].cells.element(boundBy: 2).tap()
	
	// check if the print version button exists
	XCTAssertTrue(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].waitForExistence(timeout: .short))
	
	// take snapshot
	snapshot("tracelocation_detail_view")
	
	// navigate to tracelocation print version view
	app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].tap()
	
	// wait for the pdf view to be loaded
	let delayExpectation = XCTestExpectation()
	delayExpectation.isInverted = true
	wait(for: [delayExpectation], timeout: .short)
	
	// take snapshot
	snapshot("tracelocation_pdf_view")
	}
	*/

}
