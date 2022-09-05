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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		let healthCertifiedPersonsExpectation = expectation(description: "healthCertifiedPersons publisher updated")
		// One for registration, one for the validity state update, and one for the wallet info update
		healthCertifiedPersonsExpectation.expectedFulfillmentCount = 4
		
		let subscription = service.$healthCertifiedPersons
			.dropFirst()
			.sink { _ in
				healthCertifiedPersonsExpectation.fulfill()
			}
		
		let vaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [
					.fake(uniqueCertificateIdentifier: "0")
				]
			),
			webTokenHeader: .fake(expirationTime: .distantPast)
		)
		let vaccinationCertificate = try HealthCertificate(base45: vaccinationCertificateBase45, validityState: .expired, isValidityStateNew: false)
		
		let result = service.registerHealthCertificate(base45: vaccinationCertificateBase45, completedNotificationRegistration: { })
		
		switch result {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.first?.base45, vaccinationCertificate.base45)
		case .failure:
			XCTFail("Registration should succeed")
		}
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [vaccinationCertificate.base45])
		
		subscription.cancel()
	}
	
	func testGIVEN_Certificate_WHEN_Register_THEN_SignatureInvalidError() throws {
		// GIVEN
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let firstTestCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			)
		)
		
		// WHEN
		let result = service.registerHealthCertificate(base45: firstTestCertificateBase45, completedNotificationRegistration: { })
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
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfigProvider,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)
		
		// Register first test certificate
		
		let firstTestCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let firstTestCertificate = try HealthCertificate(base45: firstTestCertificateBase45)
		
		var registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45, completedNotificationRegistration: { })
		
		var registeredFirstTestCertificate: HealthCertificate?
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstTestCertificate.base45])
			XCTAssertNil(certificateResult.registrationDetail)
			registeredFirstTestCertificate = certificateResult.certificate
		case .failure:
			XCTFail("Registration should succeed")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [firstTestCertificate.base45])
		
		// By default added certificate are not marked as new
		XCTAssertFalse(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 0]).isNew)
		XCTAssertEqual(service.unseenNewsCount.value, 0)
		
		// Try to register same certificate twice
		
		registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45, markAsNew: true, completedNotificationRegistration: { })
		
		if case .failure(let error) = registrationResult, case .certificateAlreadyRegistered = error { } else {
			XCTFail("Double registration of the same certificate should fail")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [firstTestCertificate.base45])
		
		// Certificates that were not added successfully don't change unseenNewsCount
		XCTAssertEqual(service.unseenNewsCount.value, 0)
		
		// Try to register certificate with too many entries
		
		let wrongCertificateBase45 = try base45Fake(digitalCovidCertificate: DigitalCovidCertificate.fake(
			vaccinationEntries: [VaccinationEntry.fake(
				dateOfVaccination: "2020-01-01"
			)],
			testEntries: [TestEntry.fake(
				dateTimeOfSampleCollection: "2020-01-02T12:00:00.000Z"
			)],
			recoveryEntries: nil
		))
		do {
			_ = try HealthCertificate(base45: wrongCertificateBase45)
		} catch {
			XCTAssertNotNil(error)
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [firstTestCertificate.base45])
		
		// Register second test certificate for same person
		
		let secondTestCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "1"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let secondTestCertificate = try HealthCertificate(base45: secondTestCertificateBase45, isNew: true)
		
		registrationResult = service.registerHealthCertificate(base45: secondTestCertificateBase45, markAsNew: true, completedNotificationRegistration: { })
		
		var registeredSecondTestCertificate: HealthCertificate?
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstTestCertificate, secondTestCertificate].map { $0.base45 })
			XCTAssertNil(certificateResult.registrationDetail)
			registeredSecondTestCertificate = certificateResult.certificate
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [firstTestCertificate, secondTestCertificate].map { $0.base45 })
		
		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 1]).isNew)
		
		// Register vaccination certificate for same person
		
		let firstVaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45, isNew: true)
		
		registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true, completedNotificationRegistration: { })
		
		var registeredFirstVaccinationCertificate: HealthCertificate?
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
			XCTAssertNil(certificateResult.registrationDetail)
			registeredFirstVaccinationCertificate = certificateResult.certificate
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .green)
		
		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates[safe: 0]).isNew)
		
		// Register vaccination certificate for other person
		
		let secondVaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let secondVaccinationCertificate = try HealthCertificate(base45: secondVaccinationCertificateBase45)
		
		registrationResult = service.registerHealthCertificate(base45: secondVaccinationCertificateBase45, completedNotificationRegistration: { })
		
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [secondVaccinationCertificate.base45])
			XCTAssertEqual(certificateResult.registrationDetail, .personWarnThresholdReached)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		
		// New health certified person comes first due to alphabetical ordering
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [secondVaccinationCertificate.base45])
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .green)
		
		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons.last?.gradientType, .green)
		
		// Register test certificate for second person
		
		let thirdTestCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MAX"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "4"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let thirdTestCertificate = try HealthCertificate(base45: thirdTestCertificateBase45)
		
		registrationResult = service.registerHealthCertificate(base45: thirdTestCertificateBase45, completedNotificationRegistration: { })
		
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [thirdTestCertificate, secondVaccinationCertificate].map { $0.base45 })
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.map { $0.base45 }, [thirdTestCertificate, secondVaccinationCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons.first?.gradientType, .green)
		
		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons.last?.gradientType, .green)
		
		// Register expired recovery certificate for a third person to check gradients are correct
		
		let firstRecoveryCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "MICHI"),
				recoveryEntries: [.fake(
					uniqueCertificateIdentifier: "5"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantPast)
		)
		let firstRecoveryCertificate = try HealthCertificate(base45: firstRecoveryCertificateBase45, validityState: .expired, isValidityStateNew: false)
		
		let personsExpectation = expectation(description: "healthCertifiedPersons publisher triggered")
		personsExpectation.expectedFulfillmentCount = 5
		
		let personsSubscription = service.$healthCertifiedPersons
			.sink { _ in
				personsExpectation.fulfill()
			}
		
		let newsExpectation = expectation(description: "unseenNewsCount publisher triggered")
		newsExpectation.expectedFulfillmentCount = 2
		
		let newsSubscription = service.unseenNewsCount
			.sink { _ in
				newsExpectation.fulfill()
			}
		
		registrationResult = service.registerHealthCertificate(base45: firstRecoveryCertificateBase45, completedNotificationRegistration: { })
		
		waitForExpectations(timeout: .short)
		personsSubscription.cancel()
		newsSubscription.cancel()
		
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstRecoveryCertificate.base45])
			XCTAssertEqual(certificateResult.registrationDetail, .personWarnThresholdReached)
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates.map { $0.base45 }, [thirdTestCertificate, secondVaccinationCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .green)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 0]).unseenNewsCount, 0)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates.map { $0.base45 }, [firstRecoveryCertificate.base45])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .green)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 1]).unseenNewsCount, 1)
		
		// Expired state does not increase unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 3)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons[safe: 1]?.healthCertificates[safe: 0]).isValidityStateNew)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons[safe: 2]?.gradientType, .green)
		XCTAssertEqual(try XCTUnwrap(store.healthCertifiedPersons[safe: 2]).unseenNewsCount, 2)
		
		// Set last person as preferred person and check that positions switched and gradients are correct
		
		service.healthCertifiedPersons.last?.isPreferredPerson = true
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .green)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates.map { $0.base45 }, [thirdTestCertificate, secondVaccinationCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .green)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 2]?.healthCertificates.map { $0.base45 }, [firstRecoveryCertificate.base45])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 2]?.gradientType, .green)
		
		// Attempt to add a 4th person, max amount was set to 3
		
		let secondRecoveryCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "AHMED", standardizedGivenName: "OMAR"),
				recoveryEntries: [.fake(
					uniqueCertificateIdentifier: "6"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantPast)
		)
		
		registrationResult = service.registerHealthCertificate(base45: secondRecoveryCertificateBase45, completedNotificationRegistration: { })
		
		switch registrationResult {
		case .success:
			XCTFail("Registration should fail")
		case .failure(let error):
			if case .tooManyPersonsRegistered = error {} else {
				XCTFail("Expected .tooManyPersonsRegistered error")
			}
		}
		
		// Remove all certificates of first person and check that person is removed and gradient is correct
		
		service.moveHealthCertificateToBin(try XCTUnwrap(registeredFirstVaccinationCertificate))
		service.moveHealthCertificateToBin(try XCTUnwrap(registeredFirstTestCertificate))
		service.moveHealthCertificateToBin(try XCTUnwrap(registeredSecondTestCertificate))
		
		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 0]?.healthCertificates.map { $0.base45 }, [thirdTestCertificate, secondVaccinationCertificate].map { $0.base45 })
		XCTAssertEqual(service.healthCertifiedPersons[safe: 0]?.gradientType, .green)
		
		XCTAssertEqual(store.healthCertifiedPersons[safe: 1]?.healthCertificates.map { $0.base45 }, [firstRecoveryCertificate.base45])
		XCTAssertEqual(service.healthCertifiedPersons[safe: 1]?.gradientType, .green)
	}
	
	func testLoadingCertificatesFromStoreAndRemovingCertificates() throws {
		let store = MockTestStore()
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		let healthCertificate1 = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "DORA"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			))
		)
		
		let healthCertificate2 = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "PHILIPP"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			))
		)
		
		let healthCertificate3 = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: DigitalCovidCertificate.fake(
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
		
		XCTAssertEqual(service.healthCertifiedPersons.map { $0.healthCertificates }, [
			[
				healthCertificate1, healthCertificate2
			],
			[
				healthCertificate3
			]
		])
		XCTAssertEqual(service.healthCertifiedPersons.map { $0.healthCertificates }, store.healthCertifiedPersons.map { $0.healthCertificates })
		
		// Removing one of multiple certificates
		
		service.moveHealthCertificateToBin(healthCertificate2)
		
		XCTAssertEqual(
			service.healthCertifiedPersons.map { $0.healthCertificates },
			[
				[
					healthCertificate1
				],
				[
					healthCertificate3
				]
			]
		)
		XCTAssertEqual(service.healthCertifiedPersons.map { $0.healthCertificates }, store.healthCertifiedPersons.map { $0.healthCertificates })
		
		// Removing last certificate of a person
		
		service.moveHealthCertificateToBin(healthCertificate1)
		
		XCTAssertEqual(
			service.healthCertifiedPersons.map { $0.healthCertificates },
			[
				[
					healthCertificate3
				]
			]
		)
		XCTAssertEqual(service.healthCertifiedPersons.map { $0.healthCertificates }, store.healthCertifiedPersons.map { $0.healthCertificates })
		
		// Removing last certificate of last person
		
		service.moveHealthCertificateToBin(healthCertificate3)
		
		XCTAssertTrue(service.healthCertifiedPersons.isEmpty)
	}
	
	func testRestoreCertificateFromRecycleBin() throws {
		let store = MockTestStore()
		let recycleBin = RecycleBin.fake(store: store)
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: recycleBin,
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)
		
		// Move certificate to bin.
		
		let firstTestCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let firstTestCertificate = try HealthCertificate(base45: firstTestCertificateBase45)
		
		recycleBin.moveToBin(.certificate(firstTestCertificate))
		
		// registerHealthCertificate() should restore the certificate from bin and return .restoredFromBin error.
		
		let registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45, completedNotificationRegistration: { })
		
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
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: try XCTUnwrap(notYetExpiringSoonDate))
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: cachedAppConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		XCTAssertEqual(healthCertificate.validityState, .valid)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .valid)
		
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testValidityStateUpdate_InvalidSignature() throws {
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				testEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: Date())
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(healthCertificate.validityState, .invalid)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .invalid)
		
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testValidityStateUpdate_Blocked() throws {
		let expiringDate = Calendar.current.date(
			byAdding: .day,
			value: 50,
			to: Date()
		)
		
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: try XCTUnwrap(expiringDate))
		)
		let healthCertificate = try HealthCertificate(base45: healthCertificateBase45)
		XCTAssertEqual(healthCertificate.validityState, .valid)
		
		let wallet = DCCWalletInfo.fake(
			certificatesRevokedByInvalidationRules: [
				DCCCertificateContainer.fake(
					certificateRef: .fake(
						barcodeData: healthCertificateBase45
					)
				)
			]
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: nil
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(wallet)
		cclService.didChange = false
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(healthCertificate.validityState, .blocked)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .blocked)
		
		let newWallet = DCCWalletInfo.fake(
			certificatesRevokedByInvalidationRules: []
		)
		cclService.dccWalletInfoResult = .success(newWallet)
		cclService.didChange = true
		
		let validExpectation = expectation(description: "validity change to valid")
		
		service.updateDCCWalletInfosIfNeeded(isForced: true, completion: {
			XCTAssertEqual(healthCertificate.validityState, .valid)
			XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .valid)
			validExpectation.fulfill()
			service.moveHealthCertificateToBin(healthCertificate)
		})
		waitForExpectations(timeout: .medium)
	}

	func testValidityStateUpdate_Revoked() throws {
		let healthCertificate = try vaccinationCertificate()
		XCTAssertEqual(healthCertificate.validityState, .valid)

		let store = MockTestStore()
		store.revokedCertificates = [healthCertificate.base45]

		let revocationProvider = MockRevocationProvider()
		revocationProvider.updateCacheResult = .success([healthCertificate])

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_COSE_NO_SIGN1),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: revocationProvider
		)

		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })

		XCTAssertEqual(healthCertificate.validityState, .revoked)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .revoked)
	}

	func testAddingCertificateUpdatesRevocationListAndValidityStateAndSchedulesNotification() throws {
		let alreadyRevokedHealthCertificate = try vaccinationCertificate(doseNumber: 1, totalSeriesOfDoses: 2)
		alreadyRevokedHealthCertificate.validityState = .revoked

		let healthCertificateToBeUnrevoked = try vaccinationCertificate(doseNumber: 2, totalSeriesOfDoses: 2, webTokenHeader: .fake(expirationTime: .distantFuture))
		healthCertificateToBeUnrevoked.validityState = .revoked

		let healthCertificateToBeRevoked = try recoveryCertificate()
		healthCertificateToBeRevoked.validityState = .valid

		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [alreadyRevokedHealthCertificate, healthCertificateToBeUnrevoked]
		)

		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		store.revokedCertificates = [alreadyRevokedHealthCertificate.base45, healthCertificateToBeUnrevoked.base45]

		let notificationCenter = MockUserNotificationCenter()

		let revocationProvider = MockRevocationProvider()
		revocationProvider.updateCacheResult = .success([alreadyRevokedHealthCertificate, healthCertificateToBeRevoked])

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: revocationProvider
		)

		service.syncSetup()

		service.addHealthCertificate(healthCertificateToBeRevoked, completedNotificationRegistration: { })

		XCTAssertEqual(alreadyRevokedHealthCertificate.validityState, .revoked)
		XCTAssertEqual(healthCertificateToBeUnrevoked.validityState, .valid)
		XCTAssertEqual(healthCertificateToBeRevoked.validityState, .revoked)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
		XCTAssertTrue(notificationCenter.notificationRequests.contains { $0.identifier.hasPrefix("HealthCertificateNotificationRevoked") })
	}
	
	func testValidityStateUpdate_JustExpired() throws {
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: Date())
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
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)
		
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testValidityStateUpdate_LongExpired() throws {
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: .distantPast)
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
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(healthCertificate.validityState, .expired)
		XCTAssertEqual(service.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expired)
		
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
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: try XCTUnwrap(expiringSoonDate))
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: cachedAppConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)
		
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_InitialWithoutDCCWalletInfo() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .seriesCompletingOrBooster,
			ageInDays: 2,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: nil
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "New Admission State"))
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo updated")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, newDCCWalletInfo)
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(healthCertifiedPerson.dccWalletInfo, newDCCWalletInfo)
		XCTAssertEqual(store.healthCertifiedPersons.first?.dccWalletInfo, newDCCWalletInfo)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_StillValidButMostRecentWalletInfoUpdateFailed() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .seriesCompletingOrBooster,
			ageInDays: 2,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: .fake(validUntil: Date(timeIntervalSinceNow: 100)),
			mostRecentWalletInfoUpdateFailed: true
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "New Admission State"))
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo updated")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, newDCCWalletInfo)
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(healthCertifiedPerson.dccWalletInfo, newDCCWalletInfo)
		XCTAssertEqual(store.healthCertifiedPersons.first?.dccWalletInfo, newDCCWalletInfo)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_MostRecentWalletInfoUpdateFailedIsSet() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .seriesCompletingOrBooster,
			ageInDays: 2,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: nil,
			mostRecentWalletInfoUpdateFailed: false
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .failure(.failedFunctionsEvaluation(FakeError.fake))
		cclService.didChange = false
		
		let expectation = expectation(description: "mostRecentWalletInfoUpdateFailed updated")
		
		let subscription = healthCertifiedPerson.$mostRecentWalletInfoUpdateFailed
			.dropFirst()
			.sink {
				XCTAssertTrue($0)
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertTrue(healthCertifiedPerson.mostRecentWalletInfoUpdateFailed)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first).mostRecentWalletInfoUpdateFailed)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_ExpiredWalletInfo() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .seriesCompletingOrBooster,
			ageInDays: 2,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: .fake(validUntil: Date(timeIntervalSinceNow: -100)),
			mostRecentWalletInfoUpdateFailed: false
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "New Admission State"))
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo updated")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, newDCCWalletInfo)
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(healthCertifiedPerson.dccWalletInfo, newDCCWalletInfo)
		XCTAssertEqual(store.healthCertifiedPersons.first?.dccWalletInfo, newDCCWalletInfo)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_ConfigurationDidChange() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .seriesCompletingOrBooster,
			ageInDays: 2,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: .fake(validUntil: Date(timeIntervalSinceNow: 100)),
			mostRecentWalletInfoUpdateFailed: false
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "New Admission State"))
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = true
		
		let expectation = expectation(description: "dccWalletInfo updated")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, newDCCWalletInfo)
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(healthCertifiedPerson.dccWalletInfo, newDCCWalletInfo)
		XCTAssertEqual(store.healthCertifiedPersons.first?.dccWalletInfo, newDCCWalletInfo)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testDCCWalletInfoUpdate_NoUpdateRequired() throws {
		let oldDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(visible: true, badgeText: .fake(string: "Old Admission State")),
			validUntil: Date(timeIntervalSinceNow: 100)
		)
		
		let healthCertificate: HealthCertificate = try vaccinationCertificate(type: .seriesCompletingOrBooster, ageInDays: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: oldDCCWalletInfo,
			mostRecentWalletInfoUpdateFailed: false
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]

		let cclService = FakeCCLService()
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo is not updated")
		expectation.isInverted = true
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink { _ in
				expectation.fulfill()
			}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(healthCertifiedPerson.dccWalletInfo, oldDCCWalletInfo)
		XCTAssertEqual(store.healthCertifiedPersons.first?.dccWalletInfo, oldDCCWalletInfo)
		
		subscription.cancel()
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testValidityStateUpdate_ExpiresSoonStateAlmostEnds() throws {
		let expirationThresholdInDays = 14
		
		let healthCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				recoveryEntries: [.fake()]
			),
			webTokenHeader: .fake(expirationTime: Date(timeIntervalSinceNow: 10))
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
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: cachedAppConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(healthCertificate.validityState, .expiringSoon)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates.first?.validityState, .expiringSoon)
		
		service.moveHealthCertificateToBin(healthCertificate)
	}
	
	func testGIVEN_HealthCertificate_WHEN_CertificatesIsInvalid_THEN_NotificationForInvalidShouldBeCreated() throws {
		// GIVEN
		let notificationCenter = MockUserNotificationCenter()
		let store = MockTestStore()
		
		let vaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-04",
					uniqueCertificateIdentifier: "91"
				)]
			)
		)
		let healthCertificate = HealthCertificate.mock(base45: vaccinationCertificateBase45, validityState: .invalid)
		
		let expectation = expectation(description: "notificationRequests changed")
		expectation.expectedFulfillmentCount = 1
		
		notificationCenter.onAdding = { _ in
			expectation.fulfill()
		}
		
		// WHEN
		// When creating the service with the store, all certificates are checked for their validityStatus and thus their notifications are created.
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(error: .HC_DSC_EXPIRED),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			digitalCovidCertificateAccess: MockDigitalCovidCertificateAccess(),
			notificationCenter: notificationCenter,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .medium)
		
		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
		XCTAssertTrue(notificationCenter.notificationRequests.contains { $0.identifier.hasPrefix("HealthCertificateNotificationInvalid") })
	}
	
	func testBoosterNotificationTriggeredFromDCCWalletInfo() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 180)
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			boosterNotification: .fake(visible: true, identifier: "Booster-Rule-Identifier")
		)
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "notificationRequests changed")
		expectation.expectedFulfillmentCount = 1
		
		notificationCenter.onAdding = { _ in
			expectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .medium)
		
		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
		XCTAssertTrue(notificationCenter.notificationRequests.contains { $0.identifier.hasPrefix("BoosterVaccinationNotification") })
	}
	
	func testNoBoosterNotificationTriggeredFromDCCWalletInfoWithoutBoosterNotification() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 180)
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			boosterNotification: .fake(visible: false, identifier: nil)
		)
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "notificationRequests changed")
		expectation.isInverted = true
		
		notificationCenter.onAdding = { _ in
			expectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(notificationCenter.notificationRequests.count, 0)
	}
	
	func testNoDuplicateBoosterNotificationTriggeredFromDCCWalletInfo() throws {
		let dccWalletInfo: DCCWalletInfo = .fake(
			boosterNotification: .fake(visible: true, identifier: "Booster-Rule-Identifier"),
			validUntil: Date(timeIntervalSinceNow: 100)
		)
		
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .incomplete,
			ageInDays: 180,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: dccWalletInfo
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(dccWalletInfo)
		cclService.didChange = true
		
		let walletExpectation = expectation(description: "dccWalletInfo updated with same booster rule")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, dccWalletInfo)
				walletExpectation.fulfill()
			}
		
		let notificationExpectation = expectation(description: "notificationRequests changed")
		notificationExpectation.isInverted = true
		
		notificationCenter.onAdding = { _ in
			notificationExpectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .short)
		
		// There should be no new notifications scheduled from the DCCWalletInfo update
		XCTAssertEqual(notificationCenter.notificationRequests.count, 0)
		
		subscription.cancel()
	}
	
	func testNoDuplicateBoosterNotificationTriggeredWhenMigratingFromOldBoosterRuleToDCCWalletInfo() throws {
		let dccWalletInfo: DCCWalletInfo = .fake(
			boosterNotification: .fake(visible: true, identifier: "Booster-Rule-Identifier"),
			validUntil: Date(timeIntervalSinceNow: 100)
		)
		
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .incomplete,
			ageInDays: 180,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: nil,
			boosterRule: .fake(identifier: "Booster-Rule-Identifier")
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(dccWalletInfo)
		cclService.didChange = true
		
		let walletExpectation = expectation(description: "dccWalletInfo updated with same booster rule")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, dccWalletInfo)
				walletExpectation.fulfill()
			}
		
		let notificationExpectation = expectation(description: "notificationRequests changed")
		notificationExpectation.isInverted = true
		
		notificationCenter.onAdding = { _ in
			notificationExpectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .short)
		
		// There should be no new notifications scheduled from the DCCWalletInfo update
		XCTAssertEqual(notificationCenter.notificationRequests.count, 0)
		
		subscription.cancel()
	}
	
	func testBoosterRuleIncreasesUnseenNewsCount() throws {
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)
		
		// Register vaccination certificate
		
		let firstVaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					doseNumber: 2,
					totalSeriesOfDoses: 2,
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "2"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45, isNew: true)
		
		let registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true, completedNotificationRegistration: { })
		
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate.base45])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates.first).isNew)
		
		// Setting booster rule increases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(boosterNotification: .fake(visible: true, identifier: "BoosterRule"))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		
		// Setting to same booster rule leaves unseen news count unchanged
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(boosterNotification: .fake(visible: true, identifier: "BoosterRule"))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		
		// Setting booster rule to nil decreases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(boosterNotification: .fake(visible: false, identifier: nil))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		
		// Setting booster rule increases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(boosterNotification: .fake(visible: true, identifier: "BoosterRule"))
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
	
	func testCertificateReissuanceNotificationTriggeredFromDCCWalletInfo() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 180)
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			certificateReissuance: .fake(
				reissuanceDivision: .fake(identifier: "test"),
				certificates: [.fake()]
			)
		)
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "notificationRequests changed")
		expectation.expectedFulfillmentCount = 1
		
		notificationCenter.onAdding = { _ in
			expectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .medium)

		XCTAssertEqual(notificationCenter.notificationRequests.count, 1)
		XCTAssertTrue(notificationCenter.notificationRequests.contains { $0.identifier.hasPrefix("CertificateReissuanceNotification") })
	}
	
	func testNoCertificateReissuanceNotificationTriggeredFromDCCWalletInfoWithoutCertificateReissuance() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(type: .incomplete, ageInDays: 180)
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			certificateReissuance: nil
		)
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "notificationRequests changed")
		expectation.isInverted = true
		
		notificationCenter.onAdding = { _ in
			expectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: MockTestStore(),
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		service.addHealthCertificate(healthCertificate, completedNotificationRegistration: { })
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(notificationCenter.notificationRequests.count, 0)
	}
	
	func testNoDuplicateCertificateReissuanceNotificationTriggeredFromDCCWalletInfo() throws {
		let healthCertificate: HealthCertificate = try vaccinationCertificate(
			type: .incomplete,
			ageInDays: 180,
			cborWebTokenHeader: .fake(expirationTime: .distantFuture)
		)
		
		let dccWalletInfo: DCCWalletInfo = .fake(
			validUntil: Date(timeIntervalSinceNow: 100),
			certificateReissuance: .fake(
				reissuanceDivision: .fake(),
				certificates: [.fake()]
			)
		)
		
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [healthCertificate],
			dccWalletInfo: dccWalletInfo
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let notificationCenter = MockUserNotificationCenter()

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(dccWalletInfo)
		cclService.didChange = true
		
		let walletExpectation = expectation(description: "dccWalletInfo updated with same certificate reissuance")
		
		let subscription = healthCertifiedPerson.$dccWalletInfo
			.dropFirst()
			.sink {
				XCTAssertEqual($0, dccWalletInfo)
				walletExpectation.fulfill()
			}
		
		let notificationExpectation = expectation(description: "notificationRequests changed")
		notificationExpectation.isInverted = true
		
		notificationCenter.onAdding = { _ in
			notificationExpectation.fulfill()
		}
		
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
		
		waitForExpectations(timeout: .short)
		
		// There should be no new notifications scheduled from the DCCWalletInfo update
		XCTAssertEqual(notificationCenter.notificationRequests.count, 0)
		
		subscription.cancel()
	}
	
	func testCertificateReissuanceIncreasesUnseenNewsCount() throws {
		let store = MockTestStore()
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.syncSetup()
		
		XCTAssertTrue(store.healthCertifiedPersons.isEmpty)
		
		// Register vaccination certificate
		
		let firstVaccinationCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "GUENDLING", standardizedGivenName: "NICK"),
				vaccinationEntries: [VaccinationEntry.fake(
					doseNumber: 2,
					totalSeriesOfDoses: 2,
					dateOfVaccination: "2021-05-28",
					uniqueCertificateIdentifier: "3"
				)]
			),
			webTokenHeader: .fake(expirationTime: .distantFuture)
		)
		let firstVaccinationCertificate = try HealthCertificate(base45: firstVaccinationCertificateBase45, isNew: true)
		
		let registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45, markAsNew: true, completedNotificationRegistration: { })
		
		switch registrationResult {
		case let .success(certificateResult):
			XCTAssertEqual(certificateResult.person.healthCertificates.map { $0.base45 }, [firstVaccinationCertificate.base45])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}
		
		// Marking as new increases unseen news count
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		XCTAssertTrue(try XCTUnwrap(store.healthCertifiedPersons.first?.healthCertificates.first).isNew)
		
		// Setting certificate reissuance increases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(certificateReissuance: .fake(reissuanceDivision: .fake(visible: true, identifier: "identifier")))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		
		// Setting to same certificate reissuance leaves unseen news count unchanged
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(certificateReissuance: .fake(reissuanceDivision: .fake(visible: true, identifier: "identifier")))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		
		// Setting certificate reissuance to nil decreases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(certificateReissuance: nil)
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		
		// Setting invisible certificate reissuance does not increase unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(certificateReissuance: .fake(reissuanceDivision: .fake(visible: false, identifier: "identifier")))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		
		// Setting certificate reissuance increases unseen news count
		store.healthCertifiedPersons.first?.dccWalletInfo = .fake(certificateReissuance: .fake(reissuanceDivision: .fake(visible: true, identifier: "newidentifier")))
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 2)
		XCTAssertEqual(service.unseenNewsCount.value, 2)
		
		// Marking certificate as seen decreases unseen news count
		store.healthCertifiedPersons.first?.healthCertificates.first?.isNew = false
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 1)
		XCTAssertEqual(service.unseenNewsCount.value, 1)
		
		// Marking certificate reissuance as seen decreases unseen news count
		store.healthCertifiedPersons.first?.isNewCertificateReissuance = false
		XCTAssertEqual(store.healthCertifiedPersons.first?.unseenNewsCount, 0)
		XCTAssertEqual(service.unseenNewsCount.value, 0)
	}
	
	func test_replaceHealthCertificate_markAsNewIsTrue() throws {
		let store = MockTestStore()
		let recycleBin = RecycleBin.fake(store: store)
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: recycleBin,
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		let firstNewCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "firstNewCertificate"
					)
				]
			)
		)
		let secondNewCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "secondNewCertificate"
					)
				]
			)
		)
		let firstNewCertificate = DCCReissuanceCertificate(certificate: firstNewCertificateBase45, relations: [DCCReissuanceRelation(index: 1, action: "replace")])
		let secondNewCertificate = DCCReissuanceCertificate(certificate: secondNewCertificateBase45, relations: [DCCReissuanceRelation(index: 0, action: "replace")])
		
		let firstOldCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "firstOldCertificate"
					)
				]
			)
		)
		let secondOldCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "secondOldCertificate"
					)
				]
			)
		)

		let person = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: firstOldCertificateBase45),
				try HealthCertificate(base45: secondOldCertificateBase45)
			]
		)
		
		store.healthCertifiedPersons = [person]
		service.updatePublishersFromStore()
		
		try service.replaceHealthCertificate(
			requestCertificates: [firstOldCertificateBase45, secondOldCertificateBase45],
			with: [firstNewCertificate, secondNewCertificate],
			for: person,
			markAsNew: true,
			completedNotificationRegistration: { }
		)
		
		XCTAssertEqual(person.healthCertificates[0].vaccinationEntry?.uniqueCertificateIdentifier, "firstNewCertificate")
		XCTAssertEqual(person.healthCertificates[1].vaccinationEntry?.uniqueCertificateIdentifier, "secondNewCertificate")
		XCTAssertTrue(person.healthCertificates[0].isNew)
		XCTAssertTrue(person.healthCertificates[1].isNew)
		XCTAssertEqual(store.recycleBinItems.count, 2)
	}
	
	func test_replaceHealthCertificate_markAsNewIsFalse() throws {
		let store = MockTestStore()
		let recycleBin = RecycleBin.fake(store: store)
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: FakeCCLService(),
			recycleBin: recycleBin,
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		let firstNewCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "firstNewCertificate"
					)
				]
			)
		)
		let secondNewCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "secondNewCertificate"
					)
				]
			)
		)
		let firstNewCertificate = DCCReissuanceCertificate(certificate: firstNewCertificateBase45, relations: [DCCReissuanceRelation(index: 1, action: "replace")])
		let secondNewCertificate = DCCReissuanceCertificate(certificate: secondNewCertificateBase45, relations: [DCCReissuanceRelation(index: 0, action: "replace")])
		
		let firstOldCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "firstOldCertificate"
					)
				]
			)
		)
		let secondOldCertificateBase45 = try base45Fake(
			digitalCovidCertificate: DigitalCovidCertificate.fake(
				vaccinationEntries: [
					VaccinationEntry.fake(
						uniqueCertificateIdentifier: "secondOldCertificate"
					)
				]
			)
		)

		let person = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: firstOldCertificateBase45),
				try HealthCertificate(base45: secondOldCertificateBase45)
			]
		)
		
		store.healthCertifiedPersons = [person]
		service.updatePublishersFromStore()
		
		try service.replaceHealthCertificate(
			requestCertificates: [firstOldCertificateBase45, secondOldCertificateBase45],
			with: [firstNewCertificate, secondNewCertificate],
			for: person,
			markAsNew: false,
			completedNotificationRegistration: { }
		)
		
		XCTAssertEqual(person.healthCertificates[0].vaccinationEntry?.uniqueCertificateIdentifier, "firstNewCertificate")
		XCTAssertEqual(person.healthCertificates[1].vaccinationEntry?.uniqueCertificateIdentifier, "secondNewCertificate")
		XCTAssertFalse(person.healthCertificates[0].isNew)
		XCTAssertFalse(person.healthCertificates[1].isNew)
		XCTAssertEqual(store.recycleBinItems.count, 2)
	}

	func testDCCAdmissionStateChanged_Then_flagIsSetInHealthCertifiedPerson() throws {
		let vaccinationHealthCertificate: HealthCertificate = try vaccinationCertificate(type: .seriesCompletingOrBooster, ageInDays: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [vaccinationHealthCertificate],
			dccWalletInfo: DCCWalletInfo.fake(
				admissionState: .fake(
					identifier: "3G",
					visible: true,
					badgeText: .fake(string: "3G"),
					subtitleText: .fake(string: "3G")
				)
			)
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(
				identifier: "2G+",
				visible: true,
				badgeText: .fake(string: "2G+")
			)
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo updated")
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.setup(updatingWalletInfos: true) {
			XCTAssertTrue(healthCertifiedPerson.isAdmissionStateChanged)
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
	
	func testDCCAdmissionStateHasNotChangedAfterUpdateIntroducingIdentifier_Then_flagIsNotSetInHealthCertifiedPerson() throws {
		let vaccinationHealthCertificate: HealthCertificate = try vaccinationCertificate(type: .seriesCompletingOrBooster, ageInDays: 2)
		let healthCertifiedPerson = HealthCertifiedPerson(
			healthCertificates: [vaccinationHealthCertificate],
			dccWalletInfo: DCCWalletInfo.fake(
				admissionState: .fake(
					identifier: nil,
					visible: true,
					badgeText: .fake(string: "3G"),
					subtitleText: .fake(string: "3G")
				)
			)
		)
		
		let store = MockTestStore()
		store.healthCertifiedPersons = [healthCertifiedPerson]
		
		let newDCCWalletInfo: DCCWalletInfo = .fake(
			admissionState: .fake(
				identifier: "2G+",
				visible: true,
				badgeText: .fake(string: "2G+")
			)
		)

		let cclService = FakeCCLService()
		cclService.dccWalletInfoResult = .success(newDCCWalletInfo)
		cclService.didChange = false
		
		let expectation = expectation(description: "dccWalletInfo updated")
		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			cclService: cclService,
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		service.setup(updatingWalletInfos: true) {
			XCTAssertFalse(healthCertifiedPerson.isAdmissionStateChanged)
			expectation.fulfill()
		}
		
		waitForExpectations(timeout: .medium)
		
		// To keep service in memory until expectation is fulfilled
		service.moveHealthCertificateToBin(vaccinationHealthCertificate)
	}

	func testSetupRemovesExpiringSoonAndExpiredNotifications() throws {
		let store = MockTestStore()
		store.expiringSoonAndExpiredNotificationsRemoved = false

		let notificationCenter = MockUserNotificationCenter()
		notificationCenter.notificationRequests = [
			UNNotificationRequest(
				identifier: "OtherNotification",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "HealthCertificateNotificationExpireSoonBlaBlaBla",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "HealthCertificateNotificationExpiredBlaBlaBla",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "HealthCertificateNotificationExpireSoon13746978374-2345-5432",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "HealthCertificateNotificationOther",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "HealthCertificateNotificationExpired13746978374-2345-5432",
				content: UNNotificationContent(),
				trigger: nil
			),
			UNNotificationRequest(
				identifier: "OtherNotification2",
				content: UNNotificationContent(),
				trigger: nil
			)
		]

		let service = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: CachedAppConfigurationMock(),
			notificationCenter: notificationCenter,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(
				restService: RestServiceProviderStub(),
				store: store
			)
		)

		service.syncSetup()

		XCTAssertTrue(store.expiringSoonAndExpiredNotificationsRemoved)
		XCTAssertEqual(
			notificationCenter.notificationRequests.map { $0.identifier },
			["OtherNotification", "HealthCertificateNotificationOther", "OtherNotification2"]
		)
	}
	
}
