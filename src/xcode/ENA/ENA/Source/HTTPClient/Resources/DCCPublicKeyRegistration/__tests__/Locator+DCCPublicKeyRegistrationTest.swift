//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class Locator_DCCPublicKeyRegistrationTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "9897043974f475dd8bf25ba97aa97b054edccfa0a28046f509eecc8cb171866e"
		let locator = Locator.dccPublicKeyRegistration(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}
	
}
