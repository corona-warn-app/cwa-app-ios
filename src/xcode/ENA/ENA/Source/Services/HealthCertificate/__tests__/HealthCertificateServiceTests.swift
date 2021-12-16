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
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")
		// One for registration, one for the validity state update and one for is validity state new update
		healthCertifiedPersonsExpectation.expectedFulfillmentCount = 3

		let subscription = service.$healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}

		let vaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [
					.fake(uniqueCertificateIdentifier: "0")
				]
			),
			and: .fake(expirationTime: .distantPast)
		)
		let vaccinationCertificate = try HealthCertificate(base45: vaccinationCertificateBase45, validityState: .expired, isValidityStateNew: true)

		let result = service.registerHealthCertificate(base45: vaccinationCertificateBase45)

		switch result {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [vaccinationCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [vaccinationCertificate])

		subscription.cancel()
	}

	func testHealthCertifiedPersonsPublisherTriggeredAndStoreUpdatedOnValidityStateChange() throws {
		let vaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [.fake(
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		let vaccinationCertificate = try HealthCertificate(base45: vaccinationCertificateBase45)

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				vaccinationCertificate
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
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")

		service.$healthCertifiedPersons
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}
			.store(in: &subscriptions)


		waitForExpectations(timeout: .short)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)
	}

	func testGIVEN_Certificate_WHEN_Register_THEN_SignatureInvalidError() throws {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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
		var thresholdFeature = SAP_Internal_V2_AppFeature()
		thresholdFeature.label = "dcc-person-warn-threshold"
		thresholdFeature.value = 2

		var maxCountFeature = SAP_Internal_V2_AppFeature()
		maxCountFeature.label = "dcc-person-count-max"
		maxCountFeature.value = 3

		var appFeatures = SAP_Internal_V2_AppFeatures()
		appFeatures.appFeatures = [thresholdFeature, maxCountFeature]

		var appConfig = SAP_Internal_V2_ApplicationConfigurationIOS()
		appConfig.appFeatures = appFeatures

		let appConfigProvider = CachedAppConfigurationMock(with: appConfig, store: MockTestStore())

		let store = MockTestStore()
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfigProvider,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [firstTestCertificate])
			XCTAssertNil(certificateResult.registrationDetail)
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
		let secondTestCertificate = try HealthCertificate(base45: secondTestCertificateBase45, isNew: true)

		registrationResult = service.registerHealthCertificate(base45: secondTestCertificateBase45, markAsNew: true)

		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [firstTestCertificate, secondTestCertificate])
			XCTAssertNil(certificateResult.registrationDetail)
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
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45, isNew: true)

		registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true)

		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
			XCTAssertNil(certificateResult.registrationDetail)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .lightBlue)

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
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [secondVaccinationCertificate])
			XCTAssertEqual(certificateResult.registrationDetail, .personWarnThresholdReached)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		// New health certified person comes first due to alphabetical ordering
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .lightBlue)

		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.last?.gradientType, .mediumBlue)

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
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .lightBlue)

		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons.last?.gradientType, .mediumBlue)

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
		let firstRecoveryCertificate = try HealthCertificate(base45: firstRecoveryCertificateBase45, validityState: .expired, isValidityStateNew: true)

		registrationResult = service.registerHealthCertificate(base45: firstRecoveryCertificateBase45)

		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [firstRecoveryCertificate])
			XCTAssertEqual(certificateResult.registrationDetail, .personWarnThresholdReached)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .lightBlue)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 0]).unseenNewsCount, 0)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .solidGrey)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 1]).unseenNewsCount, 1)

		// Expired state increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 3)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons[safe: 1]?.healthCertificates[safe: 0]).isValidityStateNew)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 2]?.gradientType, .darkBlue)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 2]).unseenNewsCount, 2)

		// Set last person as preferred person and check that positions switched and gradients are correct

		service.healthCertifiedPersons.last?.isPreferredPerson = true

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .lightBlue)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .mediumBlue)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 2]?.gradientType, .solidGrey)

		// Attempt to add a 4th person, max amount was set to 3

		let secondRecoveryCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "AHMED", standardizedGivenName: "OMAR"),
				recoveryEntries: [.fake(
					uniqueCertificateIdentifier: "6"
				)]
			),
			and: .fake(expirationTime: .distantPast)
		)

		registrationResult = service.registerHealthCertificate(base45: secondRecoveryCertificateBase45)

		switch registrationResult {
		case .success:
			XCTFail("Registration should fail")
		case .failure(let error):
			if case .tooManyPersonsRegistered = error {} else {
				XCTFail("Expected .tooManyPersonsRegistered error")
			}
		}

		// Remove all certificates of first person and check that person is removed and gradient is correct

		service.moveHealthCertificateToBin(firstVaccinationCertificate)
		service.moveHealthCertificateToBin(firstTestCertificate)
		service.moveHealthCertificateToBin(secondTestCertificate)

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .lightBlue)

		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates, [firstRecoveryCertificate])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .solidGrey)
	}

	func testLoadingCertificatesFromStoreAndRemovingCertificates() throws {
		let store = MockTestStore()
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertTrue(service.healthCertifiedPersons.isEmpty)

		// Loading certificates from the store

		service.updatePublishersFromStore()

		XCTAssertEqual(service.healthCertifiedPersons, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate1, healthCertificate2
			]),
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons, store.healthCertifiedPersons)

		// Removing one of multiple certificates

		service.moveHealthCertificateToBin(healthCertificate2)

		XCTAssertEqual(service.healthCertifiedPersons, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate1
			]),
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons, store.healthCertifiedPersons)

		// Removing last certificate of a person

		service.moveHealthCertificateToBin(healthCertificate1)

		XCTAssertEqual(service.healthCertifiedPersons, [
			HealthCertifiedPerson(healthCertificates: [
				healthCertificate3
			])
		])
		XCTAssertEqual(service.healthCertifiedPersons, store.healthCertifiedPersons)

		// Removing last certificate of last person

		service.moveHealthCertificateToBin(healthCertificate3)

		XCTAssertTrue(service.healthCertifiedPersons.isEmpty)
	}

	func testRestoreCertificateFromRecycleBin() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let recycleBin = RecycleBin.fake(store: store)

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: recycleBin
		)

		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)

		// Move certificate to bin.

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

		recycleBin.moveToBin(.certificate(firstTestCertificate))

		// registerHealthCertificate() should restore the certificate from bin and return .restoredFromBin error.

		let registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		guard case let .success(certificateResult) = registrationResult else {
				  XCTFail("certificateResult expected.")
				  return
		}
		XCTAssertEqual(certificateResult.registrationDetail, .restoredFromBin)
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
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: cachedAppConfig,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		XCTAssertEqual(healthCertificate.validityState, .valid)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .valid)

		service.moveHealthCertificateToBin(healthCertificate)
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
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .invalid)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .invalid)

		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}

	func testValidityStateUpdate_JustExpired() throws {
		let healthCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				vaccinationEntries: [.fake()]
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
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)

		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
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
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)

		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
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
		let client = ClientMock()

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: cachedAppConfig,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)

		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
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
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: cachedAppConfig,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)

		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let requestsSubscription = service.$testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = service.$healthCertifiedPersons
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

		service.healthCertifiedPersons.first?.healthCertificates.first?.isValidityStateNew = false
		service.healthCertifiedPersons.first?.healthCertificates.first?.isNew = false

		waitForExpectations(timeout: .medium)

		requestsSubscription.cancel()
		personsSubscription.cancel()
		countSubscription.cancel()

		XCTAssertEqual(
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 2
		let personsSubscription = service.$healthCertifiedPersons
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
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 2
		let personsSubscription = service.$healthCertifiedPersons
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
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 2
		let personsSubscription = service.$healthCertifiedPersons
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
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertEqual(service.testCertificateRequests.first, testCertificateRequest)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 2
		let personsSubscription = service.$healthCertifiedPersons
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
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertEqual(service.testCertificateRequests.first, testCertificateRequest)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertEqual(service.testCertificateRequests.first, testCertificateRequest)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertEqual(service.testCertificateRequests.first, testCertificateRequest)
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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

		XCTAssertEqual(service.testCertificateRequests.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_PCRAndNoLabId_dgcNotSupportedByLabErrorReturned() {
		let store = MockTestStore()
		let client = ClientMock()
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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
		
		XCTAssertEqual(service.testCertificateRequests.count, 1)
		XCTAssertTrue(service.testCertificateRequests[0].requestExecutionFailed)
		XCTAssertFalse(service.testCertificateRequests[0].isLoading)
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
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			// Return error on signature check to ensure the certificate is registered regardless
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_DSC_NO_MATCH),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		let requestsSubscription = service.$testCertificateRequests
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
			try XCTUnwrap(service.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(service.testCertificateRequests.isEmpty)
	}
	
	func testGIVEN_HealthCertificate_WHEN_CertificatesAreAddedAndRemoved_THEN_NotificationsShouldBeCreatedAndRemoved() throws {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let notificationCenter = MockUserNotificationCenter()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			notificationCenter: notificationCenter,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
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
		service.moveHealthCertificateToBin(recoveryCertificate)
		
		// THEN
		// There should be now 1 notifications for expireSoon and 1 for expired. Test certificates are ignored. The recovery is now removed. Remains the two notifications for the vaccination certificate.
		XCTAssertEqual(notificationCenter.notificationRequests.count, 2)
	}
	
	func testGIVEN_HealthCertificate_WHEN_CertificatesIsInvalid_THEN_NotificationForInvalidShouldBeCreated() throws {
		
		// GIVEN
		let notificationCenter = MockUserNotificationCenter()
		let store = MockTestStore()
				
		let vaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-04",
					uniqueCertificateIdentifier: "91"
				)]
			)
		)
		let healthCertificate = HealthCertificate.mock(base45: vaccinationCertificateBase45, validityState: .invalid)
		
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [
				   healthCertificate
			   ]
		   )
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		// WHEN
		// When creating the service with the store, all certificates are checked for their validityStatus and thus their notifications are created.
		let client = ClientMock()
		_ = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_DSC_EXPIRED),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			notificationCenter: notificationCenter,
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)
		
		// There should be now 1 notification for invalid, 1 for expireSoon and 1 for expired.
		XCTAssertEqual(notificationCenter.notificationRequests.count, 3)
	}

	func testBoosterRuleIncreasesUnseenNewsCount() throws {
		let store = MockTestStore()
		let client = ClientMock()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)

		// Register vaccination certificate

		let firstVaccinationCertificateBase45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					doseNumber: 2,
					totalSeriesOfDoses: 2,
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			),
			and: .fake(expirationTime: .distantFuture)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45, isNew: true)

		let registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true)

		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates, [firstVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates.first).isNew)

		// Setting booster rule increases unseen news count
		store.healthCertifiedPersons.first?.boosterRule = .fake()
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)

		// Setting to same booster rule leaves unseen news count unchanged
		store.healthCertifiedPersons.first?.boosterRule = .fake()
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)

		// Setting booster rule to nil decreases unseen news count
		store.healthCertifiedPersons.first?.boosterRule = nil
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)

		// Setting booster rule increases unseen news count
		store.healthCertifiedPersons.first?.boosterRule = .fake()
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)

		// Marking certificate as seen decreases unseen news count
		store.healthCertifiedPersons.first?.healthCertificates.first?.isNew = false
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)

		// Marking booster rule as seen decreases unseen news count
		store.healthCertifiedPersons.first?.isNewBoosterRule = false
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 0)
		XCTAssertEqual(service.unseenNewsCount.value, 0)
	}

	func testBoosterRuleIsResetOnNoPassedResultError() throws {
		let store = MockTestStore()
		store.healthCertifiedPersons = [
			HealthCertifiedPerson(
				healthCertificates: [.mock(base45: HealthCertificateMocks.firstBase45Mock)],
				boosterRule: .fake()
			)
		]

		let boosterNotificationsService = FakeBoosterNotificationsService(result: .failure(.BOOSTER_VALIDATION_ERROR(.NO_PASSED_RESULT)))

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)

		let registrationResult = service.registerHealthCertificate(base45: HealthCertificateMocks.lastBase45Mock)

		switch registrationResult {
		case .success:
			XCTAssertNil(store.healthCertifiedPersons.first?.boosterRule)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
	}

	func testBoosterRuleIsResetOnNoVaccinationCertificateError() throws {
		let store = MockTestStore()
		store.healthCertifiedPersons = [
			HealthCertifiedPerson(
				healthCertificates: [.mock(base45: HealthCertificateMocks.firstBase45Mock)],
				boosterRule: .fake()
			)
		]

		let boosterNotificationsService = FakeBoosterNotificationsService(result: .failure(.BOOSTER_VALIDATION_ERROR(.NO_VACCINATION_CERTIFICATE)))

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)

		let registrationResult = service.registerHealthCertificate(base45: HealthCertificateMocks.lastBase45Mock)

		switch registrationResult {
		case .success:
			XCTAssertNil(store.healthCertifiedPersons.first?.boosterRule)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
	}

	func testBoosterRuleIsNotResetOnRuleServerError() throws {
		let store = MockTestStore()
		store.healthCertifiedPersons = [
			HealthCertifiedPerson(
				healthCertificates: [.mock(base45: HealthCertificateMocks.firstBase45Mock)],
				boosterRule: .fake()
			)
		]

		let boosterNotificationsService = FakeBoosterNotificationsService(result: .failure(.CERTIFICATE_VALIDATION_ERROR(.RULE_SERVER_ERROR(.boosterNotification))))

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)

		let registrationResult = service.registerHealthCertificate(base45: HealthCertificateMocks.lastBase45Mock)

		switch registrationResult {
		case .success:
			XCTAssertNotNil(store.healthCertifiedPersons.first?.boosterRule)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
	}

	func testBoosterRuleIsNotResetOnNoNetworkError() throws {
		let store = MockTestStore()
		store.healthCertifiedPersons = [
			HealthCertifiedPerson(
				healthCertificates: [.mock(base45: HealthCertificateMocks.firstBase45Mock)],
				boosterRule: .fake()
			)
		]

		let boosterNotificationsService = FakeBoosterNotificationsService(result: .failure(.CERTIFICATE_VALIDATION_ERROR(.NO_NETWORK)))

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			boosterNotificationsService: boosterNotificationsService,
			recycleBin: .fake()
		)

		let registrationResult = service.registerHealthCertificate(base45: HealthCertificateMocks.lastBase45Mock)

		switch registrationResult {
		case .success:
			XCTAssertNotNil(store.healthCertifiedPersons.first?.boosterRule)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
	}

}
