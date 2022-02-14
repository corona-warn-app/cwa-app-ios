//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_TeleTanTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "fc722406a9d4cea83c885e8c7d04112718e00873854248840ee6ad32a3b137de"
		let locator = Locator.teleTan(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
