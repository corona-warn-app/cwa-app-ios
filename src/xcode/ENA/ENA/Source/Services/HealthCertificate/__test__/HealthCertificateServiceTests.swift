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

	// swiftlint:disable:next cyclomatic_complexity
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

		var registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		switch registrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [firstTestCertificate])
		case .failure:
			XCTFail("Registration should succeed")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 1)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstTestCertificate])

		// Try to register same certificate twice

		registrationResult = service.registerHealthCertificate(base45: firstTestCertificateBase45)

		if case .failure(let error) = registrationResult, case .certificateAlreadyRegistered = error { } else {
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

		registrationResult = service.registerHealthCertificate(base45: secondTestCertificateBase45)

		switch registrationResult {
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

		registrationResult = service.registerHealthCertificate(base45: firstVaccinationCertificateBase45)

		switch registrationResult {
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

		registrationResult = service.registerHealthCertificate(base45: secondVaccinationCertificateBase45)

		switch registrationResult {
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

		registrationResult = service.registerHealthCertificate(base45: thirdTestCertificateBase45)

		switch registrationResult {
		case.success(let healthCertifiedPerson):
			XCTAssertEqual(healthCertifiedPerson.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
		case .failure(let error):
			XCTFail("Registration should succeed, failed with error: \(error.localizedDescription)")
		}

		XCTAssertEqual(store.healthCertifiedPersons.count, 2)
		XCTAssertEqual(store.healthCertifiedPersons.first?.healthCertificates, [firstVaccinationCertificate, firstTestCertificate, secondTestCertificate])
		XCTAssertEqual(store.healthCertifiedPersons.last?.healthCertificates, [thirdTestCertificate, secondVaccinationCertificate])
	}

	func testLoadingCertificatesFromStoreAndRemovingCertificates() throws {
		let store = MockTestStore()

		let service = HealthCertificateService(
			store: store,
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock()
		)

		let healthCertificate1 = try HealthCertificate(
			base45: try base45Fake(from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "PHILIPP"),
				testEntries: [TestEntry.fake(
					dateTimeOfSampleCollection: "2021-04-30T22:34:17.595Z",
					uniqueCertificateIdentifier: "0"
				)]
			))
		)

		let healthCertificate2 = try HealthCertificate(
			base45: try base45Fake(from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "PHILIPP"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-05-14",
					uniqueCertificateIdentifier: "3"
				)]
			))
		)

		let healthCertificate3 = try HealthCertificate(
			base45: try base45Fake(from: DigitalGreenCertificate.fake(
				name: .fake(standardizedFamilyName: "MUSTERMANN", standardizedGivenName: "DORA"),
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
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
		)

		let requestsSubscription = service.testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let personsExpectation = expectation(description: "Persons not empty")
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
		let countSubscription = service.unseenTestCertificateCount
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

		service.resetUnseenTestCertificateCount()

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
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
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
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
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
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
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
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalGreenCertificateAccess: MockDigitalGreenCertificateAccess()
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
			from: DigitalGreenCertificate.fake(
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
		)

		let personsExpectation = expectation(description: "Persons not empty")
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

		var digitalGreenCertificateAccess = MockDigitalGreenCertificateAccess()
		digitalGreenCertificateAccess.convertedToBase45 = .failure(.AES_DECRYPTION_FAILED)

		let service = HealthCertificateService(
			store: store,
			client: client,
			appConfiguration: CachedAppConfigurationMock(),
			digitalGreenCertificateAccess: digitalGreenCertificateAccess
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
			client: ClientMock(),
			appConfiguration: CachedAppConfigurationMock(),
			digitalGreenCertificateAccess: MockDigitalGreenCertificateAccess()
		)

		let expectation = expectation(description: "Completion is called.")
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
				expectation.fulfill()
				return
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
		
		XCTAssertEqual(service.testCertificateRequests.value.count, 1)
		XCTAssertTrue(service.testCertificateRequests.value[0].requestExecutionFailed)
		XCTAssertFalse(service.testCertificateRequests.value[0].isLoading)
	}
}
