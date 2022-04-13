//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest
import HealthCertificateToolkit

class HealthCertificateService_GroupingAfterDeletionTests: XCTestCase {

	func testGIVEN_6Certificates_WHEN_CertificateAreRegistered_THEN_GroupingCreatesTwoPersons() throws {

		// GIVEN

		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		let certificateSingle1 = try certificateSingle1()
		let certificateSingle2 = try certificateSingle2()
		let certificateSingle3 = try certificateSingle3()
		let certificateSingle4 = try certificateSingle4()
		let certificateSingleA = try certificateSingleA()
		let certificateCombiner = try certificateCombiner()

		var listOfCertificates = [
			certificateSingle3,
			certificateSingle1,
			certificateSingle2,
			certificateSingle4,
			certificateCombiner,
			certificateSingleA
		]
		listOfCertificates.shuffle()
		listOfCertificates.forEach { service.registerHealthCertificate(base45: $0, completedNotificationRegistration: { }) }

		// We should have now 2 persons. Person1 with four certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
	}
	
	func testGIVEN_PersonWith3Certificates_WHEN_CertificateIsDeleted_THEN_RemainingStaysAtSamePersons() throws {
		
		// GIVEN
		
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		let certificateSingle1 = try certificateSingle1()
		let certificateSingle2 = try certificateSingle2()
		let certificateSingle3 = try certificateSingle3()
		let certificateSingle4 = try certificateSingle4()
		let certificateSingleA = try certificateSingleA()
		let certificateCombiner = try certificateCombiner()
		
		var listOfCertificates = [
			certificateCombiner,
			certificateSingle1,
			certificateSingle2,
			certificateSingle3,
			certificateSingle4,
			certificateSingleA
		]
		listOfCertificates.shuffle()
		listOfCertificates.forEach { service.registerHealthCertificate(base45: $0, completedNotificationRegistration: { }) }
		
		
		// We should have now 2 persons. Person1 with four certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
		
		// WHEN
		
		guard let person = service.healthCertifiedPersons.first,
			  let certificateToRemove = person.healthCertificates.first(where: { $0.base45 == certificateSingle1 }) else {
				  XCTFail("Person should not be empty")
				  return
			  }
		
		// Remove a single-stand-alone certifcate from Person1.
		service.moveHealthCertificateToBin(certificateToRemove)
		
		// THEN
		
		// We should have now still 2 persons. Person1 with three certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
		
		let donald = service.healthCertifiedPersons[0]
		let gustav = service.healthCertifiedPersons[1]
		XCTAssertEqual(donald.healthCertificates.count, 4)
		XCTAssertEqual(gustav.healthCertificates.count, 1)
		
		// Donald does not contain the deleted certificate.
		XCTAssertFalse(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle1
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle2
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle3
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle4
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateCombiner
		}))
		
		// Gustav does not contain the deleted certificate.
		XCTAssertFalse(gustav.healthCertificates.contains(where: {
			$0.base45 == certificateSingle1
		}))
		
		XCTAssertTrue(gustav.healthCertificates.contains(where: {
			$0.base45 == certificateSingleA
		}))
	}
	
	func testGIVEN_PersonWith3Certificates_WHEN_CertificateIsDeleted_THEN_RemainingSplitsUpInto2Persons() throws {
		
		// GIVEN
		
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		
		let certificateSingle1 = try certificateSingle1()
		let certificateSingle2 = try certificateSingle2()
		let certificateSingle3 = try certificateSingle3()
		let certificateSingle4 = try certificateSingle4()
		let certificateSingleA = try certificateSingleA()
		let certificateCombiner = try certificateCombiner()
		
		var listOfCertificates = [
			certificateCombiner,
			certificateSingle1,
			certificateSingle2,
			certificateSingle3,
			certificateSingle4,
			certificateSingleA
		]
		
		listOfCertificates.shuffle()
		listOfCertificates.forEach { service.registerHealthCertificate(base45: $0, completedNotificationRegistration: { }) }
		
		// We should have now 2 persons. Person1 with four certificates and Person2 with one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
		
		// WHEN
		
		guard let originalPerson = service.healthCertifiedPersons.first,
			  let certificateToRemove = originalPerson.healthCertificates.first(where: { $0.base45 == certificateCombiner }) else {
				  XCTFail("Person should not be empty")
				  return
			  }
		
		// Remove the combining certifcate from Person1.
		service.moveHealthCertificateToBin(certificateToRemove)
		
		// THEN
		
		// We should have now 3 persons. Person1 with three certificates, and Person2 and Person3 with each one certificate.
		XCTAssertEqual(service.healthCertifiedPersons.count, 3)
		XCTAssertTrue(service.healthCertifiedPersons.contains(originalPerson))
		
		let donald = service.healthCertifiedPersons[0]
		let quack = service.healthCertifiedPersons[1]
		let gustav = service.healthCertifiedPersons[2]

		XCTAssertEqual(donald.healthCertificates.count, 3)
		XCTAssertEqual(gustav.healthCertificates.count, 1)
		XCTAssertEqual(quack.healthCertificates.count, 1)

		// Donald does not contain the deleted certificate.
		XCTAssertFalse(donald.healthCertificates.contains(where: {
			$0.base45 == certificateCombiner
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle1
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle3
		}))
		
		XCTAssertTrue(donald.healthCertificates.contains(where: {
			$0.base45 == certificateSingle4
		}))
		
		// Gustav does not contain the deleted certificate.
		XCTAssertFalse(gustav.healthCertificates.contains(where: {
			$0.base45 == certificateCombiner
		}))
		
		XCTAssertTrue(gustav.healthCertificates.contains(where: {
			$0.base45 == certificateSingleA
		}))
		
		// Quack does not contain the deleted certificate.
		XCTAssertFalse(quack.healthCertificates.contains(where: {
			$0.base45 == certificateCombiner
		}))
		
		XCTAssertTrue(quack.healthCertificates.contains(where: {
			$0.base45 == certificateSingle2
		}))
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
