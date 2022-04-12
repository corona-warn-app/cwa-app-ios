//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_ServiceIdentityDocumentValidationDecoratorTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "4d8341b9cef4b25b9499283e2a07af1d3cd3d84cb02fe7b32eb47968b98148f0"
		let dummyURL = try XCTUnwrap(URL(string: "https://www.coronawarn.app"))
		let locator = Locator.serviceIdentityDocumentValidationDecorator(url: dummyURL)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	func testGIVEN_LocatorCom_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "ea527922fc5e9d5feedf8a4926ac29bf86aa58c68b1d7efa260c79b4704fde9f"
		let dummyURL = try XCTUnwrap(URL(string: "https://www.coronawarn.com"))
		let locator = Locator.serviceIdentityDocumentValidationDecorator(url: dummyURL)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
