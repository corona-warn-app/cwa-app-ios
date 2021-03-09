////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HomeTraceLocationsCellModelTests: XCTestCase {

	func testGIVEN_HomeTraceLocationsCellModel_THEN_InitilizedAsExpected() {
		// GIVEN
		let cellModel = HomeTraceLocationsCellModel()

		// THEN
		XCTAssertEqual(cellModel.title, AppStrings.Home.traceLocationsCardTitle)
		XCTAssertEqual(cellModel.description, AppStrings.Home.traceLocationsCardBody)
		XCTAssertEqual(cellModel.buttonTitle, AppStrings.Home.traceLocationsCardButton)
		XCTAssertEqual(cellModel.image, UIImage(named: "Illu_TraceLocations"))
		XCTAssertEqual(cellModel.accessibilityIdentifier, AccessibilityIdentifiers.Home.traceLocationsCardButton)
	}

}
