//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine
import HealthCertificateToolkit

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class HealthCertificateServiceTests: CWATestCase {

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdatedOnCertificateRegistration() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")
		// One for registration, one for the validity state update and one for is validity state new update
		healthCertifiedPersonsExpectation.expectedFulfillmentCount = 3

		let subscription = service.healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let testCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			),
			and: .fake(expirationTime: .distantPast)
		)
		let testCertificate = try HealthCertificate(base45: testCertificateBase45, validityState: .expired)

		let result = service.registerHealthCertificate(base45: testCertificateBase45)

		switch result {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [testCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [testCertificate])

		subscription.cancel()
	}

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdatedOnValidityStateChange() throws {
		let testCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		let testCertificate = try HealthCertificate(base45: testCertificateBase45)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   testCertificate
			   ]
		   )

		var subscriptions = Set<AnyCancellable>()

		let healthCertifiedPersonExpectation = expectation(description: "healthCertifiedPerson objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertifiedPersonExpectation.expectedFulfillmentCount = 2

		healthCertifiedPerson
			.objectDidChange
			.sink { _ in
				healthCertifiedPersonExpectation.fulfill()
			}
			.store(in: &subscriptions)

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		service.healthCertifiedPersons
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}
			.store(in: &subscriptions)


		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)
	}

	func testGIVEN_Certificate_WHEN_Register_THEN_SignatureInvalidError() throws {
		// GIVEN
		let service = HealthCertificateService(
			store: MockTestStore(),
			signatureVerifying: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)

		// WHEN
		let result = service.registerHealthCertificate(base45: firstTestCertificateBase45)
		var invalidSignatureError: Bool = false
		if case .failure(.invalidSignature) = result {
			invalidSignatureError = true
		} else {
			XCTFail("Unexpected .success or error")
		}

		// THEN
		XCTAssertTrue(invalidSignatureError)
	}

	// swiftlint:disable cyclomatic_complexity
	// swiftlint:disable:next function_body_length
	func testRegisteringCertificates() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)

		// Register first test certificate

		let firstTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let firstTestCertificate = try HealthCertificate(base45: firstTestCertificateBase45)

		var registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstTestCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// By default added certificate are not marked as new
		XCTAssertFalse(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 0]).isNew)
		XCTAssertEqual(service.unseenNewsCount.value, 0)

		// Try to register same certificate twice

		registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45, markAsNew: true)

		if case .failure(let error) = registrationResult, case .certificateAlreadyRegistered = error { } else {
			XCTFail("Double registration of the same certificate should fail")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// Certificates that were not added successfully don't change unseenNewsCount
		XCTAssertEqual(service.unseenNewsCount.value, 0)

		// Try to register certificate with too many entries

		let wrongCertificateBase45 = try base45Fake(from: DigitalCovidCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: "2020-01-01"
			)],
			testEntries: [TestEntry.fake(
				dateTimeOfSampleCollection: "2020-01-02T12:00:00.000Z"
			)],
			recoveryEntries: nil
		))

		let wrongCertificate = try HealthCertificate(base45: wrongCertificateBase45)

		XCTAssertTrue(wrongCertificate.hasTooManyEntries)

		registrationResult = service.registerHealthCertificate(base45: wrongCertificateBase45)

		if case .failure(let error) = registrationResult, case .certificateHasTooManyEntries = error { } else {
			XCTFail("Registration of a certificate with too many entries should fail")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// Register second test certificate for same person

		let secondTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "1"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let secondTestCertificate = try HealthCertificate(base45: secondTestCertificateBase45)

		registrationResult = service.registerHealthCertificate(base45: secondTestCertificateBase45, markAsNew: true)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstTestCertificate, secondTestCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate, secondTestCertificate])

		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 1]).isNew)

		// Register vaccination certificate for same person

		let firstVaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45)

		registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.gradientType, .lightBlue(withStars: true))

		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 0]).isNew)

		// Register vaccination certificate for other person

		let secondVaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let secondVaccinationCertificate = try HealthCertificate(base45: secondVaccinationCertificateBase45)

		registrationResult = service.registerHealthCertificate(base45: secondVaccinationCertificateBase45)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		// New health certified person comes first due to alphabetical ordering
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.gradientType, .lightBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value.last?.gradientType, .mediumBlue(withStars: true))

		// Register test certificate for second person

		let thirdTestCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "4"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let thirdTestCertificate = try HealthCertificate(base45: thirdTestCertificateBase45)

		registrationResult = service.registerHealthCertificate(base45: thirdTestCertificateBase45)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.gradientType, .lightBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value.last?.gradientType, .mediumBlue(withStars: true))

		// Register expired recovery certificate for a third person to check gradients are correct

		let firstRecoveryCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MICHI"),
				recoveryEntries: [.fake(
					uniqueCertificateIdentifier: "5"
				)]
			),
			and: .fake(expirationTime: .distantPast)
		)
		let firstRecoveryCertificate = try HealthCertificate(base45: firstRecoveryCertificateBase45, validityState: .expired)

		registrationResult = service.registerHealthCertificate(base45: firstRecoveryCertificateBase45)

		switch registrationResult {
		case let .success((healthCertifiedPerson, _)):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstRecoveryCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 0]?.gradientType, .lightBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 1]?.gradientType, .solidGrey(withStars: true))

		// Expired state increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 3)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons[safe: 1]?.healthCertificates[safe: 0]).isValidityStateNew)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 2]?.gradientType, .darkBlue(withStars: true))

		// Set last person as preferred person and check that positions switched and gradients are correct

		service.healthCertifiedPersons.value.last?.isPreferredPerson = true

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 0]?.gradientType, .lightBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 1]?.gradientType, .mediumBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 2]?.gradientType, .solidGrey(withStars: true))

		// Remove all certificates of first person and check that person is removed and gradient is correct

		service.removeHealthCertificate(firstVaccinationCertificate)
		service.removeHealthCertificate(firstTestCertificate)
		service.removeHealthCertificate(secondTestCertificate)

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 0]?.gradientType, .lightBlue(withStars: true))

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.value[safe: 1]?.gradientType, .solidGrey(withStars: true))
	}

	func testLoadingCertificatesFromStoreAndRemovingCertificates() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertificate1 = try HealthCertificate(
			base45: try base45Fake(from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "DORA"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			))
		)

		let healthCertificate2 = try HealthCertificate(
			base45: try base45Fake(from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "PHILIPP"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			))
		)

		let healthCertificate3 = try HealthCertificate(
			base45: try base45Fake(from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "PHILIPP"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-16T22:34:17.595Z",
					uniqueCertificateIdentifier: "2"
				)]
			))
		)

		store.healthCertifiedPersons = [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate1, healthCertificate2
			]),
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		]

		XCTAssertTrue(service.healthCertifiedPersons.value.isEmpty)

		// Loading certificates from the store

		service.updatePublishersFromStore()

		XCTAssertEqual(service.healthCertifiedPersons.value, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate1, healthCertificate2
			]),
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons.value, store.healthCertifiedPersons)

		// Removing one of multiple certificates

		service.removeHealthCertificate(healthCertificate2)

		XCTAssertEqual(service.healthCertifiedPersons.value, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate1
			]),
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons.value, store.healthCertifiedPersons)

		// Removing last certificate of a person

		service.removeHealthCertificate(healthCertificate1)

		XCTAssertEqual(service.healthCertifiedPersons.value, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons.value, store.healthCertifiedPersons)

		// Removing last certificate of last person

		service.removeHealthCertificate(healthCertificate3)

		XCTAssertTrue(service.healthCertifiedPersons.value.isEmpty)
	}

	func testValidityStateUpdate_Valid() throws {
		let expirationThresholdInDays = 14
		let expiringSoonDate = Calendar.current.date(
			byAdding: .day,
			value: Int(expirationThresholdInDays),
			to: Date()
		)

		let notYetExpiringSoonDate = Calendar.current.date(
			byAdding: .second,
			value: 10,
			to: try XCTUnwrap(expiringSoonDate)
		)

		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			and: .fake(expirationTime: try XCTUnwrap(notYetExpiringSoonDate))
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_DGCParameters()
		parameters.expirationThresholdInDays = UInt32(expirationThresholdInDays)
		appConfig.dgcParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: cachedAppConfig
		)

		XCTAssertEqual(healthCertificate.validityState, .valid)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .valid)

		service.removeHealthCertificate(healthCertificate)
	}

	func testValidityStateUpdate_InvalidSignature() throws {
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [.fake()]
			),
			and: .fake(expirationTime: Date())
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let healthCertificateExpectation = expectation(description: "healthCertificate objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertificateExpectation.expectedFulfillmentCount = 2

		let subscription = healthCertificate
			.objectDidChange
			.sink {
				healthCertificateExpectation.fulfill()
				XCTAssertEqual($0.validityState, .invalid)
			}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .invalid)
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.healthCertificates.first?.validityState, .invalid)

		subscription.cancel()
		service.removeHealthCertificate(healthCertificate)
	}

	func testValidityStateUpdate_JustExpired() throws {
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [.fake()]
			),
			and: .fake(expirationTime: Date())
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let healthCertificateExpectation = expectation(description: "healthCertificate objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertificateExpectation.expectedFulfillmentCount = 2

		let subscription = healthCertificate
			.objectDidChange
			.sink {
				healthCertificateExpectation.fulfill()
				XCTAssertEqual($0.validityState, .expired)
			}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.healthCertificates.first?.validityState, .expired)

		subscription.cancel()
		service.removeHealthCertificate(healthCertificate)
	}

	func testValidityStateUpdate_LongExpired() throws {
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				vaccinationEntries: [.fake()]
			),
			and: .fake(expirationTime: .distantPast)
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let healthCertificateExpectation = expectation(description: "healthCertificate objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertificateExpectation.expectedFulfillmentCount = 2

		let subscription = healthCertificate
			.objectDidChange
			.sink {
				healthCertificateExpectation.fulfill()
				XCTAssertEqual($0.validityState, .expired)
			}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.value.first?.healthCertificates.first?.validityState, .expired)

		subscription.cancel()
		service.removeHealthCertificate(healthCertificate)
	}

	func testValidityStateUpdate_ExpiresSoonStateBegins() throws {
		let expirationThresholdInDays = 14
		let expiringSoonDate = Calendar.current.date(
			byAdding: .day,
			value: Int(expirationThresholdInDays),
			to: Date()
		)

		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			and: .fake(expirationTime: try XCTUnwrap(expiringSoonDate))
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_DGCParameters()
		parameters.expirationThresholdInDays = UInt32(expirationThresholdInDays)
		appConfig.dgcParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)

		let healthCertificateExpectation = expectation(description: "healthCertificate objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertificateExpectation.expectedFulfillmentCount = 2

		let subscription = healthCertificate
			.objectDidChange
			.sink {
				healthCertificateExpectation.fulfill()
				XCTAssertEqual($0.validityState, .expiringSoon)
			}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: cachedAppConfig
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)

		subscription.cancel()
		service.removeHealthCertificate(healthCertificate)
	}

	func testValidityStateUpdate_ExpiresSoonStateAlmostEnds() throws {
		let expirationThresholdInDays = 14

		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			and: .fake(expirationTime: Date(timeIntervalSinceNow: 10))
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		var parameters = SAP_Internal_V2_DGCParameters()
		parameters.expirationThresholdInDays = UInt32(expirationThresholdInDays)
		appConfig.dgcParameters = parameters
		let cachedAppConfig = CachedAppConfigurationMock(with: appConfig)

		let healthCertificateExpectation = expectation(description: "healthCertificate objectDidChange publisher updated")
		// One for validity state and one for is validity state new
		healthCertificateExpectation.expectedFulfillmentCount = 2

		let subscription = healthCertificate
			.objectDidChange
			.sink {
				healthCertificateExpectation.fulfill()
				XCTAssertEqual($0.validityState, .expiringSoon)
			}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: cachedAppConfig
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)

		subscription.cancel()
		service.removeHealthCertificate(healthCertificate)
	}

	func testTestCertificateRegistrationAndExecution_Success() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey called")
		client.onDCCRegisterPublicKey = { _, _, _, completion in
			registerPublicKeyExpectation.fulfill()
			completion(.success(()))
		}

		var keyPair: DCCRSAKeyPair?

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? keyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let requestsSubscription = service.testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 5
		let personsSubscription = service.healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let expectedCounts = [0, 1, 0]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = expectedCounts.count
		var receivedCounts = [Int]()
		let countSubscription = service.unseenNewsCount
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		let completionExpectation = expectation(description: "registerAndExecuteTestCertificateRequest completion called")
		service.registerAndExecuteTestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			retryExecutionIfCertificateIsPending: false,
			labId: "SomeLabId"
		) { _ in
			completionExpectation.fulfill()
		}

		// Wait for certificate registration to succeed
		wait(for: [completionExpectation], timeout: .medium)

		service.healthCertifiedPersons.value.first?.healthCertificates.first?.isValidityStateNew = false
		service.healthCertifiedPersons.value.first?.healthCertificates.first?.isNew = false

		waitForExpectations(timeout: .medium)

		requestsSubscription.cancel()
		personsSubscription.cancel()
		countSubscription.cancel()

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
		XCTAssertEqual(receivedCounts, expectedCounts)
	}

	func testTestCertificateExecution_NewTestCertificateRequest() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date()
		)

		store.testCertificateRequests = [testCertificateRequest]

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey called")
		client.onDCCRegisterPublicKey = { _, _, _, completion in
			registerPublicKeyExpectation.fulfill()
			completion(.success(()))
		}

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? testCertificateRequest.rsaKeyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = service.healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Request expected to succeed")
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		personsSubscription.cancel()

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
	}

	func testTestCertificateExecution_ExistingUnregisteredKeyPair_Success() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: false
		)

		store.testCertificateRequests = [testCertificateRequest]

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey called")
		client.onDCCRegisterPublicKey = { _, _, _, completion in
			registerPublicKeyExpectation.fulfill()
			completion(.success(()))
		}

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? testCertificateRequest.rsaKeyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = service.healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Request expected to succeed")
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		personsSubscription.cancel()

		XCTAssertEqual(testCertificateRequest.rsaKeyPair, keyPair)

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
	}

	func testTestCertificateExecution_ExistingUnregisteredKeyPair_AlreadyRegisteredError() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: false
		)

		store.testCertificateRequests = [testCertificateRequest]

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey called")
		client.onDCCRegisterPublicKey = { _, _, _, completion in
			registerPublicKeyExpectation.fulfill()
			completion(.failure(.tokenAlreadyAssigned))
		}

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? testCertificateRequest.rsaKeyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = service.healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Request expected to succeed")
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		personsSubscription.cancel()

		XCTAssertEqual(testCertificateRequest.rsaKeyPair, keyPair)

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
	}

	func testTestCertificateExecution_ExistingUnregisteredKeyPair_NetworkError() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: false
		)

		store.testCertificateRequests = [testCertificateRequest]

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey called")
		client.onDCCRegisterPublicKey = { _, _, _, completion in
			registerPublicKeyExpectation.fulfill()
			completion(.failure(.noNetworkConnection))
		}

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		getDigitalCovid19CertificateExpectation.isInverted = true
		client.onGetDigitalCovid19Certificate = { _, _, _ in
			getDigitalCovid19CertificateExpectation.fulfill()
		}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess()
		)

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Request expected to fail")
				case .failure(let error):
					if case .publicKeyRegistrationFailed(let publicKeyError) = error,
					   case .noNetworkConnection = publicKeyError {} else {
						XCTFail("No network error on public key registration expected")
					}
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(service.testCertificateRequests.value.first, testCertificateRequest)
		XCTAssertFalse(testCertificateRequest.rsaPublicKeyRegistered)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_ExistingRegisteredKeyPair_Success() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: true
		)

		store.testCertificateRequests = [testCertificateRequest]

		let registerPublicKeyExpectation = expectation(description: "dccRegisterPublicKey not called")
		registerPublicKeyExpectation.isInverted = true
		client.onDCCRegisterPublicKey = { _, _, _, _ in
			registerPublicKeyExpectation.fulfill()
		}

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? testCertificateRequest.rsaKeyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = service.healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: false,
			completion: { result in
				switch result {
				case .success:
					break
				case .failure:
					XCTFail("Request expected to succeed")
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		personsSubscription.cancel()

		XCTAssertEqual(testCertificateRequest.rsaKeyPair, keyPair)

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
	}

	func testTestCertificateExecution_GettingCertificateFailsTwiceWithPending() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: true
		)

		store.testCertificateRequests = [testCertificateRequest]

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		getDigitalCovid19CertificateExpectation.expectedFulfillmentCount = 2
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.failure(.dccPending))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig
		)

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: true,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Request expected to fail")
				case .failure(let error):
					if case .certificateRequestFailed(let certificateRequestError) = error,
					   case .dccPending = certificateRequestError {} else {
						XCTFail("DCC pending error on certificate request expected")
					}
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(service.testCertificateRequests.value.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_AssemblyFails_Base64DecodingFailed() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: true,
			encryptedDEK: "dataEncryptionKey",
			encryptedCOSE: ""
		)

		store.testCertificateRequests = [testCertificateRequest]

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		getDigitalCovid19CertificateExpectation.isInverted = true
		client.onGetDigitalCovid19Certificate = { _, _, _ in
			getDigitalCovid19CertificateExpectation.fulfill()
		}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: true,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Request expected to fail")
				case .failure(let error):
					if case .base64DecodingFailed = error {} else {
						XCTFail("Base 64 decoding failed error expected")
					}
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(service.testCertificateRequests.value.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_AssemblyFails_DecryptionFailed() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: true,
			encryptedDEK: "",
			encryptedCOSE: ""
		)

		store.testCertificateRequests = [testCertificateRequest]

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		getDigitalCovid19CertificateExpectation.isInverted = true
		client.onGetDigitalCovid19Certificate = { _, _, _ in
			getDigitalCovid19CertificateExpectation.fulfill()
		}

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock()
		)

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: true,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Request expected to fail")
				case .failure(let error):
					if case .decryptionFailed = error {} else {
						XCTFail("Decryption failed error expected")
					}
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(service.testCertificateRequests.value.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_AssemblyFails_AssemblyFailed() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let keyPair = try DCCRSAKeyPair(registrationToken: "registrationToken")
		let testCertificateRequest = TestCertificateRequest(
			coronaTestType: .antigen,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			rsaKeyPair: keyPair,
			rsaPublicKeyRegistered: true,
			encryptedDEK: try keyPair.encrypt(Data()).base64EncodedString(),
			encryptedCOSE: ""
		)

		store.testCertificateRequests = [testCertificateRequest]

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		getDigitalCovid19CertificateExpectation.isInverted = true
		client.onGetDigitalCovid19Certificate = { _, _, _ in
			getDigitalCovid19CertificateExpectation.fulfill()
		}

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .failure(.AES_DECRYPTION_FAILED)

		let service = HealthCertificateService(
			store: store,
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let completionExpectation = expectation(description: "completion called")
		service.executeTestCertificateRequest(
			testCertificateRequest,
			retryIfCertificateIsPending: true,
			completion: { result in
				switch result {
				case .success:
					XCTFail("Request expected to fail")
				case .failure(let error):
					if case .assemblyFailed(let assemblyError) = error,
					   case .AES_DECRYPTION_FAILED = assemblyError {} else {
						XCTFail("Assembly failed with AES decryption failed error expected")
					}
				}
				completionExpectation.fulfill()
			}
		)

		waitForExpectations(timeout: .medium)

		XCTAssertEqual(service.testCertificateRequests.value.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_PCRAndNoLabId_dgcNotSupportedByLabErrorReturned() {

		let service = HealthCertificateService(
			store: MockTestStore(),
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess()
		)

		let completionExpectation = expectation(description: "Completion is called.")
		service.registerAndExecuteTestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "",
			registrationDate: Date(),
			retryExecutionIfCertificateIsPending: true,
			labId: nil
		) { result in
			guard case let .failure(error) = result,
				  case .dgcNotSupportedByLab = error else {
				XCTFail("Error dgcNotSupportedByLab was expected.")
				completionExpectation.fulfill()
				return
			}
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(service.testCertificateRequests.value.count, 1)
		XCTAssertTrue(service.testCertificateRequests.value[0].requestExecutionFailed)
		XCTAssertFalse(service.testCertificateRequests.value[0].isLoading)
	}

	func testTestCertificateRegistrationAndExecution_SignatureNotCheckedOnRegistration() throws {
		let client = ClientMock()

		var keyPair: DCCRSAKeyPair?

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? keyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: MockTestStore(),
			// Return error on signature check to ensure the certificate is registered regardless
			signatureVerifying: DCCSignatureVerifyingStub(error: .HC_DSC_NO_MATCH),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess
		)

		let requestsSubscription = service.testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let completionExpectation = expectation(description: "registerAndExecuteTestCertificateRequest completion called")
		service.registerAndExecuteTestCertificateRequest(
			coronaTestType: .pcr,
			registrationToken: "registrationToken",
			registrationDate: Date(),
			retryExecutionIfCertificateIsPending: false,
			labId: "SomeLabId"
		) { result in
			if case .failure = result {
				XCTFail("Success expected")
			}

			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)

		requestsSubscription.cancel()

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.value.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.value.isEmpty)
	}
	
	func testGIVEN_HealthCertificate_WHEN_CertificatesAreAddedAndRemoved_THEN_NotificationsShouldBeCreatedAndRemoved() throws {
		// GIVEN
		let notificationCenter = MockUserNotificationCenter()
		let service = HealthCertificateService(
			store: MockTestStore(),
			signatureVerifying: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			notificationCenter: notificationCenter
		)
		
		let testCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-07-22T22:22:22.225Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		
		let vaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		
		let recoveryCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				recoveryEntries: [RecoveryEntry.fake(
					dateOfFirstPositiveNAAResult: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
		let recoveryCertificate = try HealthCertificate(base45: recoveryCertificateBase45)
		
		// WHEN
		_ = service.registerHealthCertificate(base45: testCertificateBase45)
		_ = service.registerHealthCertificate(base45: vaccinationCertificateBase45)
		_ = service.registerHealthCertificate(base45: recoveryCertificateBase45)
		
		// THEN
		// There should be now 2 notifications for expireSoon and 2 for expired (One for each the vaccination and the recovery certificate). Test certificates are ignored.
		XCTAssertEqual(notificationCenter.notificationRequests.count, 4)
		
		// WHEN
		service.removeHealthCertificate(recoveryCertificate)
		
		// THEN
		// There should be now 1 notifications for expireSoon and 1 for expired. Test certificates are ignored. The recovery is now removed. Remains the two notifications for the vaccination certificate.
		XCTAssertEqual(notificationCenter.notificationRequests.count, 2)
	}

}
