//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_DCCReissuanceTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "9a2c3e66bd12c787e52ccbd17f0eb0bed1a358e42f58fa4b23bdfbb1fa619f82"
		let locator = Locator.dccReissuance

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
