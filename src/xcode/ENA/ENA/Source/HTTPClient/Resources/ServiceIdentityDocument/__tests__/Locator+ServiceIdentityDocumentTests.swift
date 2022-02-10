//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class Locator_ServiceIdentityDocumentTests: XCTestCase {

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "4d8341b9cef4b25b9499283e2a07af1d3cd3d84cb02fe7b32eb47968b98148f0"
		let dummyURL = try XCTUnwrap(URL(string: "https://www.coronawarn.app"))
		let locator = Locator.serviceIdentityDocument(endpointUrl: dummyURL)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

	func testGIVEN_LocatorDe_WHEN_getUniqueIdentifier_THEN_IsSameAsKnowUniqueIdentifier() throws {
		// GIVEN
		let knownUniqueIdentifier = "5d0e41eac7c612a64c6da9fd4a48adb26501673f1d822d8d7664f6afecb651b5"
		let dummyURL = try XCTUnwrap(URL(string: "https://www.coronawarn.de"))
		let locator = Locator.serviceIdentityDocument(endpointUrl: dummyURL)

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
