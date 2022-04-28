//
// 🦠 Corona-Warn-App
//

import XCTest

@testable import ENA

class AvailableHoursTests: CWATestCase {

	func testGIVEN_Locator_WHEN_getPath_THEN_isCorrect() {
		// GIVEN
		let locator = Locator.availableHours(day: "2020-04-20", country: "IT")

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
				"2020-04-20",
				"hour"
			], paths)

	}

	func testGIVEN_Locator_WHEN_getUniqueIdentifier_THEN_IsSameAsKnownidentifier() {
		// GIVEN
		let knownUniqueIdentifier = "0c9bac572c347e9b4fa6f1b5c74caac1ec25558d3130e347ff4b5a0d8dae8904"
		let locator = Locator.availableHours(day: "2020-04-20", country: "IT")

		// WHEN
		let uniqueIdentifier = locator.uniqueIdentifier

		// THEN
		XCTAssertEqual(uniqueIdentifier, knownUniqueIdentifier)
	}

}
