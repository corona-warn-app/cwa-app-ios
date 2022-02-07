//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificate_BelongsToSamePersonTests: XCTestCase {

	func test_BelongsToSamePerson() throws {
		let bundle = Bundle(for: Name_ExtensionTests.self)
		guard let url = bundle.url(forResource: "dcc-holder-comparison", withExtension: "json"),
			  let data = FileManager.default.contents(atPath: url.path)
			  else {
				  XCTFail("Could not load json with testcases.")
				  return
		}
		let testCases = try JSONDecoder().decode(TestCases.self, from: data).data
		
		for testCase in testCases {
			let lhsCertificate = try HealthCertificate(
				base45: try base45Fake(
					from: DigitalCovidCertificate.fake(
						name: Name.fake(
							standardizedFamilyName: testCase.actHolderA.nam.fnt,
							standardizedGivenName: testCase.actHolderA.nam.gnt
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
							standardizedFamilyName: testCase.actHolderB.nam.fnt,
							standardizedGivenName: testCase.actHolderB.nam.gnt
						),
						dateOfBirth: testCase.actHolderB.dob
					)
				),
				validityState: .valid
			)
			
			XCTAssertEqual(lhsCertificate.belongsToSamePerson(rhsCertificate), testCase.expIsSameHolder, "Test failed. Description: \(testCase.description)")
		}
	}
	
	private struct TestCases: Decodable {
		let data: [TestCase]
	}

	private struct TestCase: Decodable {
		let description: String
		let actHolderA: Holder
		let actHolderB: Holder
		let expIsSameHolder: Bool
	}
	
	private struct Holder: Decodable {
		let nam: TesCaseName
		let dob: String
	}
	
	private struct TesCaseName: Decodable {
		let gnt: String
		let fnt: String
	}
}
