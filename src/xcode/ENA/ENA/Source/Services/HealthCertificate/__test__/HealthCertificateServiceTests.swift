//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

class HealthCertificateServiceTests: CWATestCase {

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdated() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		let subscription = service.healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let testCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		let testCertificate = try HealthCertificate(base45: testCertificateBase45)

		let result = service.registerHealthCertificate(base45: testCertificateBase45)

		switch result {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [testCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [testCertificate])

		subscription.cancel()
	}

	func testRegisteringCertificates() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)

		// Register first test certificate

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		let firstTestCertificate = try HealthCertificate(base45: firstTestCertificateBase45)

		let registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		switch registrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstTestCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// Try to register same certificate twice

		let secondRegistrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		if case .failure(let error) = secondRegistrationResult, case .certificateAlreadyRegistered = error { } else {
			XCTFail("Double registration of the same certificate should fail")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// Register second test certificate for same person

		let secondTestCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		let secondTestCertificate = try HealthCertificate(base45: secondTestCertificateBase45)

		let thirdRegistrationResult = service.registerHealthCertificate(base45: secondTestCertificateBase45)

		switch thirdRegistrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstTestCertificate, secondTestCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate, secondTestCertificate])

		// Register vaccination certificate for same person

		let firstVaccinationCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45)

		let fourthRegistrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45)

		switch fourthRegistrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])

		// Register vaccination certificate for other person

		let secondVaccinationCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			)
		)
		let secondVaccinationCertificate = try HealthCertificate(base45: secondVaccinationCertificateBase45)

		let fifthRegistrationResult = service.registerHealthCertificate(base45: secondVaccinationCertificateBase45)

		switch fifthRegistrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [secondVaccinationCertificate])

		// Register test certificate for second person

		let thirdTestCertificateBase45 = try base45Fake(
			from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "4"
				)]
			)
		)
		let thirdTestCertificate = try HealthCertificate(base45: thirdTestCertificateBase45)

		let sixthRegistrationResult = service.registerHealthCertificate(base45: thirdTestCertificateBase45)

		switch sixthRegistrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
	}

	// MARK: - Private

	enum Base45FakeError: Error {
		case failed
	}

	private func base45Fake(from digitalGreenCertificate: DigitalGreenCertificate) throws -> Base45 {
		let base45Result = DigitalGreenCertificateFake.makeBase45Fake(
			from: digitalGreenCertificate,
			and: CBORWebTokenHeader.fake()
		)

		guard case let .success(base45) = base45Result else {
			XCTFail("Could not make fake base45 certificate")
			throw Base45FakeError.failed
		}

		return base45
	}

}
