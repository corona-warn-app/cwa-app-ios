//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class Locator_AllowListTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "93ffa87908f70aaf2fbc80d03c2f20d0406e5445a13d3efe9fbb987113c8c21f"
		let locator = Locator.allowList

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}
	
}
