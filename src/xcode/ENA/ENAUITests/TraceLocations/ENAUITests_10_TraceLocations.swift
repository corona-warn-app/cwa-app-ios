////
// 🦠 Corona-Warn-App
//

import XCTest

class ENAUITests_10_TraceLocations: XCTestCase {

	var app: XCUIApplication!
	
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		setupSnapshot(app)
		app.setDefaults()
		app.launchArguments.append(contentsOf: ["-isOnboarded", "YES"])
		app.launchArguments.append(contentsOf: ["-setCurrentOnboardingVersion", "YES"])
	}

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

}
