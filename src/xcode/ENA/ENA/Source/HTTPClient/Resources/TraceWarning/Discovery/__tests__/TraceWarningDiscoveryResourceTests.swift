//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class TraceWarningDiscoveryResourceTests: CWATestCase {

	// MARK: - Locator

	func testGIVEN_Locator_WHEN_getPathEncrypted_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.traceWarningDiscovery(unencrypted: false, country: "DE", isFake: false)

		// WHEN
		let paths = locator.paths

		// THEN
		XCTAssertEqual(
			[
				"version",
				"v2",
				"twp",
				"country",
				"DE",
				"hour"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getPathUnencrypted_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.traceWarningDiscovery(unencrypted: true, country: "DE", isFake: false)

		// WHEN
		let paths = locator.paths

		// THEN
		XCTAssertEqual(
			[
				"version",
				"v1",
				"twp",
				"country",
				"DE",
				"hour"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownIdentifier() {
		// GIVEN
		let knownUniqueIdentifier01 = "d6ec2715571f3bdaf55562dfa9ebf75766229f04f707c65bcf11669cec3da65e"
		let knownUniqueIdentifier02 = "cabbfc3ebad59462315431c97532c72c7226d30b7bfa1c00df92fb5827f793af"
		let unencryptedLocator = Locator.traceWarningDiscovery(unencrypted: true, country: "DE", isFake: false)
		let encryptedLocator = Locator.traceWarningDiscovery(unencrypted: false, country: "DE", isFake: false)

		// WHEN
		let uniqueIdentifier01 = unencryptedLocator.uniqueIdentifier
		let uniqueIdentifier02 = encryptedLocator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier01, knownUniqueIdentifier01)
		XCTAssertEqual(uniqueIdentifier02, knownUniqueIdentifier02)
	}

}
