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
		app.launchArguments.append(contentsOf: ["-resetFinishedDeltaOnboardings", "YES"])
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
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
		app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()
		
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
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
		app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()
		
		// THEN
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.General.primaryFooterButton].exists)
	}

  func test_traceLocation_print_flow() throws {
		app.launch()

		// navigate to tracelocation card
		app.swipeUp(velocity: .fast)
		
		// check if the tracelocation card exists
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].waitForExistence(timeout: .short))
		
		// take snapshot
		snapshot("tracelocation_card_home")

		// navigate to tracelocation overview
		app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()

		// take snapshot
		snapshot("tracelocation_overview")

		// navigate to tracelocation detail view for second item
		app.cells.element(boundBy: 2).tap()
	
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
}
