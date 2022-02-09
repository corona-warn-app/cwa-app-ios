//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_RegistrationTokenTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "63f353d7970ae09782ddd387ab51659e623e0f1c66f21ef3317c67e42c852eef"
		let locator = Locator.registrationToken(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
