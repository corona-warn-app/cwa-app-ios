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
		for testCase in testCases {
			let name = Name(familyName: "", givenName: "", standardizedFamilyName: testCase.actName, standardizedGivenName: "")
			XCTAssertEqual(name.familyNameGroupingComponents, testCase.expectedNameComponents, "Failed test case: \(testCase.description	)")
		}
	}
	
	struct TestCase {
		let description: String
		let actName: String
		let expectedNameComponents: [String]
	}
	
	let testCases = [
		TestCase(
			description: "a proper ICAO name is not sanitized",
			actName: "ERIKA",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "a proper ICAO name with multiple components is not sanitized",
			actName: "ERIKA<MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "a lower-case name is transformed to upper case",
			actName: "Erika",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "space separators are replaced",
			actName: "ERIKA MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "leading and trailing whitespace is trimmed",
			actName: "  ERIKA  ",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "leading and trailing chevrons are trimmed",
			actName: "<<<ERIKA<<<",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "multiple chevrons are normalized",
			actName: "ERIKA<<<MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "multiple space separators are normalized",
			actName: "ERIKA    MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "a dash separator is normalized",
			actName: "ERIKA-MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "a leading doctor's degree is filtered out (one separator)",
			actName: "DR<ERIKA",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "a leading doctor's degree is filtered out (two separators)",
			actName: "DR<<ERIKA",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "a trailing doctor's degree is filtered out (one separator)",
			actName: "ERIKA<DR",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "a trailing doctor's degree is filtered out (two separators)",
			actName: "ERIKA<<DR",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "a doctor's degree somewhere in the middle is filtered out",
			actName: "ERIKA<DR<MARIA",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "a doctor's degree with dot",
			actName: "Dr. Erika",
			expectedNameComponents: [
				"ERIKA"
			]
		),
		TestCase(
			description: "dots treated as separator",
			actName: "Erika.Maria",
			expectedNameComponents: [
				"ERIKA",
				"MARIA"
			]
		),
		TestCase(
			description: "German umlauts are sanitized (upper-case input)",
			actName: "CÄCILIE<BÖRGE<YÜSRA<SIßI",
			expectedNameComponents: [
				"CAECILIE",
				"BOERGE",
				"YUESRA",
				"SISSI"
			]
		),
		TestCase(
			description: "German umlauts are sanitized (lower-case input)",
			actName: "Cäcilie<Börge<Yüsra<Sißi",
			expectedNameComponents: [
				"CAECILIE",
				"BOERGE",
				"YUESRA",
				"SISSI"
			]
		),
		TestCase(
			description: "empty name results in empty components",
			actName: "",
			expectedNameComponents: []
		)
	]
}
