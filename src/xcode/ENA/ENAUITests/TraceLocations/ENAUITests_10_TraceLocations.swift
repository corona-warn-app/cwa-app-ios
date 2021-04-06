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
	
	func testCreateTraceLocation() throws {
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
		
		let descriptionInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.descriptionPlaceholder]
		let locationInputField = app.textFields[AccessibilityIdentifiers.TraceLocation.Configuration.addressPlaceholder]
		
		descriptionInputField.tap()
		descriptionInputField.typeText("Kantine")
		locationInputField.tap()
		locationInputField.typeText("Berlin")
		
		app.buttons["AppStrings.ExposureSubmission.primaryButton"].tap()
		acc()
	
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

	func acc() {
		let b1 =         AccessibilityLabels.labelsOfElement(app.buttons)
		let b2 = AccessibilityLabels.accIdentifiersOfElement(app.buttons)
		let b3 =      AccessibilityLabels.accLabelsOfElement(app.buttons)

		let s1 =         AccessibilityLabels.labelsOfElement(app.staticTexts)
		let s2 = AccessibilityLabels.accIdentifiersOfElement(app.staticTexts)
		let s3 =      AccessibilityLabels.accLabelsOfElement(app.staticTexts)

		let c1 =         AccessibilityLabels.labelsOfElement(app.cells)
		let c2 = AccessibilityLabels.accIdentifiersOfElement(app.cells)
		let c3 =      AccessibilityLabels.accLabelsOfElement(app.cells)

		let t1 =         AccessibilityLabels.labelsOfElement(app.textFields)
		let t2 = AccessibilityLabels.accIdentifiersOfElement(app.textFields)
		let t3 =      AccessibilityLabels.accLabelsOfElement(app.textFields)

		let i1 = AccessibilityLabels.labelsOfElement(app.images)
		let i2 = AccessibilityLabels.accIdentifiersOfElement(app.images)
		let i3 = AccessibilityLabels.accLabelsOfElement(app.images)
	}
}
