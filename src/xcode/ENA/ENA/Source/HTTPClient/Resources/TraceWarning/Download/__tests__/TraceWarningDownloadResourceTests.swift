//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class TraceWarningDownloadResourceTests: CWATestCase {

	// MARK: - Locator

	func testGIVEN_Locator_WHEN_getPathEncrypted_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.traceWarningPackageDownload(unencrypted: false, country: "DE", packageId: 12, isFake: false)

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
				"hour",
				"12"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getPathUnencrypted_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.traceWarningPackageDownload(unencrypted: true, country: "DE", packageId: 12, isFake: false)

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
				"hour",
				"12"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownIdentifier() {
		// GIVEN
		let knownUniqueIdentifier01 = "7d3987a1c6f7ea772914c9f3c05a211e2e6e86475f67c010048859789c03de69"
		let knownUniqueIdentifier02 = "67c2c3eebe0686f1a51bcbfe83c661b141cf411227f9ab769ec2efe98535f64b"
		let unencryptedLocator = Locator.traceWarningPackageDownload(unencrypted: true, country: "DE", packageId: 12, isFake: false)
		let encryptedLocator = Locator.traceWarningPackageDownload(unencrypted: false, country: "DE", packageId: 12, isFake: false)

		// WHEN
		let uniqueIdentifier01 = unencryptedLocator.uniqueIdentifier
		let uniqueIdentifier02 = encryptedLocator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier01, knownUniqueIdentifier01)
		XCTAssertEqual(uniqueIdentifier02, knownUniqueIdentifier02)
	}

}
