//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class Locator_AppConfigurationTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "b08be93fa394c0d59475d181eed8c4ca11ae130cc0fe247c1bcad75bd60140c9"
		let locator = Locator.appConfiguration

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
