//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_TicketValidationResultTokenTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "4a31977b2be8cc625b9220c6a1414774bb0b831b5f2a343c94918137e167cfcd"
		let urlEndpoint = try XCTUnwrap(URL(string: "https://testservice.coronawarn.app"))
		let locator = Locator.ticketValidationResultToken(resultTokenServiceURL: urlEndpoint, jwt: "123")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
