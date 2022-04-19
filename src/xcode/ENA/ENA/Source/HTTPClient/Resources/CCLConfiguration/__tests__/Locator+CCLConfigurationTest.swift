//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_CCLConfigurationTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "b4f065feda7b87f0de440516d6edae6d1d3348d75eb8bba6c473d8ee6111fcfe"
		let locator = Locator.CCLConfiguration(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
