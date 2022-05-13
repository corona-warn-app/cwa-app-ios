//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_CCLConfigurationTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "0f24d96b87439f0b817b573407bc175f6a6c257991b02d87a3e1e53ef75ad11f"
		let locator = Locator.CCLConfiguration(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
