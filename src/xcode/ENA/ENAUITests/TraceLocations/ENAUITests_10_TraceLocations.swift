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
