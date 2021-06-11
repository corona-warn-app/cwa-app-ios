////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateTests: XCTestCase {
			
	func testGIVEN_Base45WellformedEncoded_WHEN_InitIsCalled_THEN_HealthCertificateIsCreated() throws {
		
		// GIVEN
		let dgcCertificate = DigitalGreenCertificate.fake()
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}

		// WHEN
		let healthCertificate = try HealthCertificate(base45: base45)

		// THEN
		XCTAssertNotNil(healthCertificate)
	}
	
	func testGIVEN_Base45WrongCBORHeaderEncoded_WHEN_InitIsCalled_THEN_FailureIsRetuend() throws {
		
		// GIVEN
		let dgcCertificate = DigitalGreenCertificate.fake()
		
		let result = DigitalGreenCertificateFake.makeBase45CorruptFake(
			from: dgcCertificate
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		let expectedError = CertificateDecodingError.HC_COSE_MESSAGE_INVALID

		// WHEN
		var healthCertificate: HealthCertificate?
		var error: CertificateDecodingError?
		do {
			healthCertificate = try HealthCertificate(base45: base45)
		} catch let err as CertificateDecodingError {
			error = err
		}
		
		// THEN
		XCTAssertNil(healthCertificate)
		XCTAssertEqual(error, expectedError)
	}
	
	func testGIVEN_Base45WrongDGCEncoded_WHEN_InitIsCalled_THEN_FailureIsRetuend() throws {
		
		// GIVEN
		let dgcCertificate = DigitalGreenCertificate.fake(dateOfBirth: "WrongDOB")
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		let someDummyError = URLSession.Response.Failure.fakeResponse
		let expectedError = CertificateDecodingError.HC_JSON_SCHEMA_INVALID(.VALIDATION_FAILED(someDummyError))

		// WHEN
		var healthCertificate: HealthCertificate?
		var error: CertificateDecodingError?
		do {
			healthCertificate = try HealthCertificate(base45: base45)
		} catch let err as CertificateDecodingError {
			error = err
		}
		
		// THEN
		XCTAssertNil(healthCertificate)
		XCTAssertEqual(error, expectedError)
	}
	
	func testGIVEN_TwoCertificates_WHEN_Compare1_THEN_CompareIsCorrect() throws {
		// GIVEN
		let dateOfVaccination1 = "2020-01-01"
		let dgcCertificate1 = DigitalGreenCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: dateOfVaccination1
			)]
		)
		
		let result1 = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate1,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base451) = result1 else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		let dateOfVaccination2 = "2019-01-01"
		let dgcCertificate2 = DigitalGreenCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: dateOfVaccination2
			)]
		)
		
		let result2 = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate2,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base452) = result2 else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		let certificate1 = try HealthCertificate(base45: base451)
		let certificate2 = try HealthCertificate(base45: base452)

		var compared = false
		
		// WHEN
		if certificate2 < certificate1 {
			compared = true
		}

		// THEN
		XCTAssertTrue(compared)
	}
	
	func testGIVEN_TwoCertificates_WHEN_Compare2_THEN_CompareIsCorrect() throws {
		// GIVEN
		let dateOfVaccination1 = "2020-01-01"
		let dgcCertificate1 = DigitalGreenCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: dateOfVaccination1
			)]
		)
		
		let result1 = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate1,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base451) = result1 else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		let dateTimeOfSampleCollection = "2019-01-01"
		let dgcCertificate2 = DigitalGreenCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: dateTimeOfSampleCollection
			)]
		)
		
		let result2 = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate2,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base452) = result2 else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		let certificate1 = try HealthCertificate(base45: base451)
		let certificate2 = try HealthCertificate(base45: base452)

		var compared = false
		
		// WHEN
		if certificate2 < certificate1 {
			compared = true
		}

		// THEN
		XCTAssertTrue(compared)
	}
	
	func testGIVEN_DGCVersion_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
		
		let expectedVersion = "1.1.1"
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			version: expectedVersion
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.version, expectedVersion)
	}
	
	func testGIVEN_DGCName_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
		
		let expectedName = Name.fake()
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			name: expectedName
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.name, expectedName)
	}
	
	func testGIVEN_DGCDateOfBirth_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
		
		let expectedDoB = "2021-06-10"
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			dateOfBirth: expectedDoB
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.dateOfBirth, expectedDoB)
	}
	
	func testGIVEN_DGCDateOfBirthDate_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
		
		let dateOfBirth = "2021-06-10"
		let expectedDateOfBirthDate = ISO8601DateFormatter.justLocalDateFormatter.date(from: dateOfBirth)
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			dateOfBirth: dateOfBirth
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.dateOfBirthDate, expectedDateOfBirthDate)
	}
	
	func testGIVEN_DGCUniqeCertificateIdentifier_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
		
		let expectedUniqueCertificateIdentifier = "01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S"
		
		let vaccinationEntry = VaccinationEntry.fake(
			uniqueCertificateIdentifier: expectedUniqueCertificateIdentifier
		)
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			vaccinationEntries: [vaccinationEntry]
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.uniqueCertificateIdentifier, expectedUniqueCertificateIdentifier)
	}
	
	func testGIVEN_DGCTestEntry_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
			
		let testEntry1 = TestEntry.fake(
			testCenter: "Frankfurt Ginnheim Stadtplatz"
		)
		
		let testEntry2 = TestEntry.fake(
			testCenter: "Karben Bürgerzentrum"
		)
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			testEntries: [testEntry2, testEntry1]
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
		
		XCTAssertEqual(healthCertificate.testEntry?.testCenter, "Karben Bürgerzentrum")
	}
	
	func testGIVEN_DGCTypeVaccination_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
			
		let expectedVaccinationEntry = VaccinationEntry.fake()
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			vaccinationEntries: [expectedVaccinationEntry]
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		let type = healthCertificate.type
		
		// THEN
		
		guard case let .vaccination(vaccinationEntry) = type else {
			XCTFail("This should only contain a vaccinationEntry, nothing else")
			return
		}
		
		XCTAssertEqual(vaccinationEntry, expectedVaccinationEntry)
	}
	
	func testGIVEN_DGCTypeTest_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
			
		let expectedTestEntry = TestEntry.fake()
		
		let dgcCertificate = DigitalGreenCertificate.fake(
			testEntries: [expectedTestEntry]
		)
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake()
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		let type = healthCertificate.type
		
		// THEN
		
		guard case let .test(testEntry) = type else {
			XCTFail("This should only contain a testEntry, nothing else")
			return
		}
		
		XCTAssertEqual(testEntry, expectedTestEntry)
	}
	
	func testGIVEN_DGCExpirationDate_WHEN_CreateHealthCertificate_THEN_IsEqual() throws {
		
		// GIVEN
			
		let expirationTime: UInt64 = 0123456798
		let expectedDate = Date(timeIntervalSince1970: TimeInterval(expirationTime))
		
		let dgcCertificate = DigitalGreenCertificate.fake()
		
		let result = DigitalGreenCertificateFake.makeBase45Fake(
			from: dgcCertificate,
			and: CBORWebTokenHeader.fake(
				expirationTime: expirationTime)
		)
		
		guard case let .success(base45) = result else {
			XCTFail("base45 should be created from a mock. Test fails now.")
			return
		}
		
		// WHEN
		
		let healthCertificate = try HealthCertificate(base45: base45)
		
		// THEN
	
		XCTAssertEqual(healthCertificate.expirationDate, expectedDate)
	}
}
