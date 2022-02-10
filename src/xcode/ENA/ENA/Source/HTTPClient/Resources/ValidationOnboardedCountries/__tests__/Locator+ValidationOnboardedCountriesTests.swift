//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_ValidationOnboardedCountriesTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "69074efe3ebd37fa26a23d53ed545ce57ba6f675724db99eb5ea56bd729cc1e1"
		let locator = Locator.validationOnboardedCountries(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
