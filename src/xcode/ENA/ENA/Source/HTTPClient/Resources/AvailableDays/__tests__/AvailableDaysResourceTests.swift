//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class AvailableDaysResourceTests: CWATestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ec4d142271653f1cae9bfa8012bc9b2ce1f5e4502ae3d266cdc58702909eb241"
		let locator = Locator.availableDays(country: "IT")
		
		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
		XCTAssertEqual(
			[
				"version",
				"v1",
				"diagnosis-keys",
				"country",
				"IT",
				"date"
			], locator.paths)
	}


}
