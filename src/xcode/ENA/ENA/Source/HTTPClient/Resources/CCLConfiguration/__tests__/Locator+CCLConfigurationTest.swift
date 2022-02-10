//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_CCLConfigurationTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "6945f9d05c93e022e25c7efcb1f0f0428bca355841b2d1a85622515dfce67db6"
		let locator = Locator.CCLConfiguration(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
