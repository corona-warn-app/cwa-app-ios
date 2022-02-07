//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_RegistrationTokenTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "fc722406a9d4cea83c885e8c7d04112718e00873854248840ee6ad32a3b137de"
		let locator = Locator.registrationToken(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
