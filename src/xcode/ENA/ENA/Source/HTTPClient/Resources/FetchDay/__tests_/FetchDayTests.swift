//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class FetchDayTests: CWATestCase {

	// MARK: Locator tests

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.diagnosisKeys(day: "2020-04-20", country: "IT")

		// WHEN
		let paths = locator.paths

		// THEN
		XCTAssertEqual(
			[
				"version",
				"v1",
				"diagnosis-keys",
				"country",
				"IT",
				"date",
				"2020-04-20"
			], paths)
	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "ca88626aeba6b7be1fff6b501d78608e4734e1f9703a0de6311137e1c535db9d"
		let locator = Locator.diagnosisKeys(day: "2020-04-22", country: "IT")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
