//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest
import HealthCertificateToolkit

class HealthCertificate_DeleteCertificateTests: XCTestCase {
	
	func testGIVEN_PersonWith3Certificates_WHEN_CertificateIsDeleted_THEN_RemainingStaysAtSamePersons() throws {
		
		// GIVEN
		
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		
		let dob = "1986-01-01"
		let certificate1 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		let certificate2 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD<DONNI"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		let certificate3 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD<DUBBY"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		service.registerHealthCertificate(base45: certificate1)
		service.registerHealthCertificate(base45: certificate2)
		service.registerHealthCertificate(base45: certificate3)
		
		// We should have now 1 person with three different certificate attributes.
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		// WHEN
		
		guard let person = service.healthCertifiedPersons.first,
			  let certificateToRemove = person.healthCertificates.first(where: { $0.base45 == certificate2 }) else {
				  XCTFail("Person should not be empty")
				  return
			  }
		
		service.moveHealthCertificateToBin(certificateToRemove)
		
		// THEN
		
		// After deleting certificate2, 1 and 3 should still match as one person so the result is still 1  person.
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
	}
	
	func testGIVEN_PersonWith3Certificates_WHEN_CertificateIsDeleted_THEN_RemainingSplitsUpInto2Persons() throws {
		
		// GIVEN
		
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		
		let dob = "1986-01-01"
		let certificate1 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		let certificate2 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD<DONNI"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		let certificate3 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DONALD",
					standardizedGivenName: "DUCK"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake()]
			)
		)
		
		service.registerHealthCertificate(base45: certificate1)
		service.registerHealthCertificate(base45: certificate2)
		service.registerHealthCertificate(base45: certificate3)
		
		// We should have now 1 person with three different certificate attributes.
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		// WHEN
		
		guard let person = service.healthCertifiedPersons.first else {
			XCTFail("Person should not be empty")
			return
		}
		
		// We remove now the second certificate because it acts like glue between 1 and 3.
		person.healthCertificates.removeAll { $0 == certificate2 }
		
		// THEN
		
		// After delering certificate2, 1 and 3 should not match as one person so the result is 2 different persons.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
	}
}
