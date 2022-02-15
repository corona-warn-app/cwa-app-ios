//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest
import HealthCertificateToolkit

class HealthCertificateService_GroupingAfterDeletionTests: XCTestCase {
	
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
		let single1 = try certificateSingle1()
		var listOfCertificates = [
			single1,
			try certificateSingle2(),
			try certificateSingle3(),
			try certificateSingle4(),
			try certificateSingleA(),
			try certificateCombiner()
		]
		listOfCertificates.shuffle()
		listOfCertificates.forEach { service.registerHealthCertificate(base45: $0) }
		
		
		// We should have now 2 persons. Person1 with four certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
		
		// WHEN
		
		guard let person = service.healthCertifiedPersons.first,
			  let certificateToRemove = person.healthCertificates.first(where: { $0.base45 == single1 }) else {
				  XCTFail("Person should not be empty")
				  return
			  }
		
		// Remove a single-stand-alone certifcate from Person1.
		service.moveHealthCertificateToBin(certificateToRemove)
		
		// THEN
		
		// We should have now still 2 persons. Person1 with three certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
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
		let combiner = try certificateCombiner()
		var listOfCertificates = [
			try certificateSingle1(),
			try certificateSingle2(),
			try certificateSingle3(),
			try certificateSingle4(),
			try certificateSingleA(),
			combiner
		]
		listOfCertificates.shuffle()
		listOfCertificates.forEach { service.registerHealthCertificate(base45: $0) }
		
		// We should have now 2 persons. Person1 with four certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
		
		// WHEN
		
		guard let originalPerson = service.healthCertifiedPersons.first,
			  let certificateToRemove = originalPerson.healthCertificates.first(where: { $0.base45 == combiner }) else {
				  XCTFail("Person should not be empty")
				  return
			  }
		
		// Remove the combining certifcate from Person1.
		service.moveHealthCertificateToBin(certificateToRemove)
		
		// THEN
		
		// We should have now 3 persons. Person1 with three certificates, and Person2 and Person3 with each one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 3)
		XCTAssertTrue(service.healthCertifiedPersons.contains(where: { $0 === originalPerson }))
	}
	
	private let dob = "1986-01-01"
	
	private func certificateCombiner() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK<QUACK",
					standardizedGivenName: "DONALD<DONNI"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
	}
	private func certificateSingle1() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
	}
	private func certificateSingle2() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "QUACK",
					standardizedGivenName: "DONNI"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
	}
	private func certificateSingle3() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD<MANFRED"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "3"
				)]
			)
		)
	}
	private func certificateSingle4() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "DUCK",
					standardizedGivenName: "DONALD<SID"
				),
				dateOfBirth: dob,
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "4"
				)]
			)
		)
	}
	private func certificateSingleA() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: Name.fake(
					standardizedFamilyName: "GANS",
					standardizedGivenName: "GUSTAV"
				),
				dateOfBirth: "1986-02-02",
				testEntries: [TestEntry.fake(
					uniqueCertificateIdentifier: "5"
				)]
			)
		)
	}
}
