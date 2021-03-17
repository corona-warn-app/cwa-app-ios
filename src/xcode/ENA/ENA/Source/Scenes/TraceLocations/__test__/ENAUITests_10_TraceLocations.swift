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
		app.launch()
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
		
	}

	func testTrace_navigate_to_InformationScreen_for_the_first_time() throws {
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "NO"])
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
		app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()
		
		XCTAssertTrue(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.TraceLocation.primaryButton].exists)

	}
	
	func testTrace_navigate_to_InformationScreen_for_the_second_time() throws {
		app.launchArguments.append(contentsOf: ["-TraceLocationsInfoScreenShown", "YES"])
		app.launch()

		XCTAssertTrue(app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].exists)
		app.buttons[AccessibilityIdentifiers.Home.traceLocationsCardButton].tap()
		
		XCTAssertFalse(app.cells[AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle].waitForExistence(timeout: .short))
		XCTAssertFalse(app.buttons[AccessibilityIdentifiers.TraceLocation.primaryButton].exists)

	}

}
