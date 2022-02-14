//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class Name_ExtensionTests: XCTestCase {

	func testGIVEN_ValidName_THEN_GroupingStandardizedNameIsEqualStandardizedName() {
		// GIVEN
		let name = Name(familyName: "Meyer", givenName: "Thomas Arming", standardizedFamilyName: "MEYER", standardizedGivenName: "THOMAS<ARMIN"
		)

		// THEN
		XCTAssertEqual(name.groupingStandardizedName, name.standardizedName)
		XCTAssertEqual(name.groupingStandardizedName, "THOMAS<ARMIN MEYER")
	}
	
	func testGIVEN_ValidName_THEN_GroupingStandardizedNameIsTrimmed() {
		// GIVEN
		let name = Name(familyName: "Meyer ", givenName: "Thomas Armin ", standardizedFamilyName: "MEYER<", standardizedGivenName: "THOMAS<ARMIN<"
		)

		// THEN
		XCTAssertEqual(name.groupingStandardizedName, "THOMAS<ARMIN MEYER")
	}

	func testGIVEN_faltyFormattedName_THEN_GroupingStandardizedNameIsNotEqualStandardizedName() {
		// GIVEN
		let name = Name(familyName: "Meyer ", givenName: "Thomas   Arming", standardizedFamilyName: "MEYER ", standardizedGivenName: "THOMAS<<<ARMIN"
		)

		// THEN
		XCTAssertNotEqual(name.groupingStandardizedName, name.standardizedName)
		XCTAssertEqual(name.groupingStandardizedName, "THOMAS<ARMIN MEYER")
	}

	func testGIVEN_ValidName_THEN_ReversedStandardizedNameFormatMatches() {
		// GIVEN
		let name = Name(familyName: "Meyer", givenName: "Thomas Arming", standardizedFamilyName: "MEYER", standardizedGivenName: "THOMAS<ARMIN"
		)

		// THEN
		XCTAssertEqual(name.reversedStandardizedName, "MEYER<<THOMAS<ARMIN")
	}

	func testGIVEN_FaultyName_THEN_ReversedStandardizedNameFormatMatches() {
		// GIVEN
		let name = Name(familyName: "Meyer", givenName: "Thomas  Arming", standardizedFamilyName: "MEYER", standardizedGivenName: "THOMAS<<ARMIN"
		)

		// THEN
		XCTAssertEqual(name.reversedStandardizedName, "MEYER<<THOMAS<<ARMIN")
	}
	
	func test_GroupingComponents() {
		let bundle = Bundle(for: Name_ExtensionTests.self)
		guard let url = bundle.url(forResource: "dcc-holder-name-components", withExtension: "json"),
			  let data = FileManager.default.contents(atPath: url.path),
			  let testCases = try? JSONDecoder().decode(TestCases.self, from: data).data else {
				  XCTFail("Could not load json with testcases.")
				  return
		}
		
		for testCase in testCases {
			let name = Name(familyName: "", givenName: "", standardizedFamilyName: testCase.actName, standardizedGivenName: "")
			XCTAssertEqual(name.familyNameGroupingComponents, testCase.expNameComponents, "Failed test case: \(testCase.description	)")
		}
	}
	
	private struct TestCases: Decodable {
		struct TestCase: Decodable {
			let description: String
			let actName: String
			let expNameComponents: [String]
		}
		
		let data: [TestCase]
	}
}
