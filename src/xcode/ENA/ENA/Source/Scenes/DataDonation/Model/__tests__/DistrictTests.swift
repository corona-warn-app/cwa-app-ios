//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DistrictTests: XCTestCase {

	func testGIVEN_FederalStateName_THEN_MatchesLastKnownValues() {
		// GIVEN
		let countStates = FederalStateName.allCases.count
		let countShortname = FederalStateShortName.allCases.count

		// THEN
		XCTAssertEqual(countStates, 16)
		XCTAssertEqual(countShortname, 16)
	}

	func testGIVEN_givenDistrictElement_THEN_ValuesAreSet() {
		// GIVEN
		let districtElement = DistrictElement(
			districtName: "Göppingen",
			districtShortName: "BW",
			districtID: 1,
			federalStateName: .badenWürttemberg,
			federalStateShortName: .bw,
			federalStateID: 1
		)

		// THEN
		XCTAssertEqual(districtElement.districtName, "Göppingen")
		XCTAssertEqual(districtElement.districtShortName, "BW")
		XCTAssertEqual(districtElement.districtID, 1)
		XCTAssertEqual(districtElement.federalStateName, .badenWürttemberg)
		XCTAssertEqual(districtElement.federalStateShortName, .bw)
		XCTAssertEqual(districtElement.federalStateID, 1)
	}

}
