//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class Locator_DigitalCovid19CertificateTest: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ff62963de7b74bab38a2e6a94c7e56d822561498b0a9a4bf2b2efaf95fffb1eb"
		let locator = Locator.digitalCovid19Certificate(isFake: false)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}
	
}
