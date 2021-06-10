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
	
	func testGIVEN_TwoCertificates_WHEN_Compare1_THEN_CompareIsCorrect() {
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
		
		let certificate1 = HealthCertificate.mock(base45: base451)
		let certificate2 = HealthCertificate.mock(base45: base452)

		var compared = false
		// WHEN
		if certificate2 < certificate1 {
			compared = true
		}

		// THEN
		XCTAssertTrue(compared)
	}
	
	func testGIVEN_TwoCertificates_WHEN_Compare2_THEN_CompareIsCorrect() {
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
		
		let certificate1 = HealthCertificate.mock(base45: base451)
		let certificate2 = HealthCertificate.mock(base45: base452)

		var compared = false
		// WHEN
		if certificate2 < certificate1 {
			compared = true
		}

		// THEN
		XCTAssertTrue(compared)
	}
}
