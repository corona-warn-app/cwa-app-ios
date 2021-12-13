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
		let name = Name(familyName: "Meyer ", givenName: "Thomas Arming ", standardizedFamilyName: "MEYER<", standardizedGivenName: "THOMAS<ARMIN<"
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

}
