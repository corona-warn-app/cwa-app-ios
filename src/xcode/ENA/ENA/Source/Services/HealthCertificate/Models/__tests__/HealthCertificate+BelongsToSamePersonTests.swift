//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificate_BelongsToSamePersonTests: XCTestCase {

	func test_BelongsToSamePerson() throws {
		for testCase in testCases {
			let lhsCertificate = try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						name: Name.fake(
							standardizedFamilyName: testCase.actHolderA.fnt,
							standardizedGivenName: testCase.actHolderA.gnt
						),
						dateOfBirth: testCase.actHolderA.dob
					)
				),
				validityState: .valid
			)
			
			let rhsCertificate = try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						name: Name.fake(
							standardizedFamilyName: testCase.actHolderB.fnt,
							standardizedGivenName: testCase.actHolderB.gnt
						),
						dateOfBirth: testCase.actHolderB.dob
					)
				),
				validityState: .valid
			)
			
			XCTAssertEqual(lhsCertificate.belongsToSamePerson(rhsCertificate), testCase.expIsSameHolder, "Test failed. Description: \(testCase.description)")
		}
	}
	
	struct TestCase {
		struct Holder {
			let gnt: String
			let fnt: String
			let dob: String
		}
		
		let description: String
		let actHolderA: Holder
		let actHolderB: Holder
		let expIsSameHolder: Bool
	}
	
	let testCases = [
		TestCase(
			description: "happy path - match",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "happy path - no match - different dob",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1970-01-01"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "happy path - no match - no matches in gnt",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ANGELIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "happy path - no match - no matches in fnt",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ANGELIKA",
				fnt: "BEISPIELFRAU",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "match despite optional middle name",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA<MARIA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "match despite last name addendum",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN<GABLER",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "no match for twins",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ANGELIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "match for twins with same middle name (false positive)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA<MARIA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ANGELIKA<MARIA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "no match for siblings with same middle name (different dob)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA<MARIA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ANGELIKA<MARIA",
				fnt: "MUSTERMANN",
				dob: "1970-01-01"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "match despite leading and trailing chevron (<)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "<ERIKA<",
				fnt: "<MUSTERMANN<",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "no match because of matching chevrons (<)",
			actHolderA: TestCase.Holder(
				gnt: "<ERIKA<",
				fnt: "<MUSTERMANN<",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "<ANGELIKA<",
				fnt: "<MUSTERMANN<",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "match despite leading and trailing whitespace",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: " ERIKA ",
				fnt: " MUSTERMANN ",
				dob: "  1980-02-03  "
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "no match because of matching whitespace",
			actHolderA: TestCase.Holder(
				gnt: " ERIKA ",
				fnt: " MUSTERMANN ",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: " ANGELIKA ",
				fnt: " MUSTERMANN ",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "match despite doctor's degree in fnt (no space)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "DR<MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "match despite doctor's degree in fnt (with space)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "DR<<MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "match despite doctor's degree in gnt (no space)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "DR<ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "match despite doctor's degree in gnt (with space)",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "DR<<ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: true
		),
		TestCase(
			description: "no match because of matching doctor's degree in gnt",
			actHolderA: TestCase.Holder(
				gnt: "DR<<ERIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "DR<<ANGELIKA",
				fnt: "MUSTERMANN",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		),
		TestCase(
			description: "no match because of matching doctor's degree in fnt",
			actHolderA: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "DR<<MUSTERMANN",
				dob: "1980-02-03"
			),
			actHolderB: TestCase.Holder(
				gnt: "ERIKA",
				fnt: "DR<<BEISPIELFRAU",
				dob: "1980-02-03"
			),
			expIsSameHolder: false
		)
	]
}
