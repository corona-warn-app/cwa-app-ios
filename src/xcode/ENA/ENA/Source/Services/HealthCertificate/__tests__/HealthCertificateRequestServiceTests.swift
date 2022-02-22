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
class HealthCertificateRequestServiceTests: CWATestCase {

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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let requestsSubscription = healthCertificateRequestService.$testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 4
		let personsSubscription = healthCertificateService.$healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let expectedCounts = [0, 1, 0]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = expectedCounts.count
		var receivedCounts = [Int]()
		let countSubscription = healthCertificateService.unseenNewsCount
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		let completionExpectation = expectation(description: "registerAndExecuteTestCertificateRequest completion called")
		healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
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

		healthCertificateService.healthCertifiedPersons.first?.healthCertificates.first?.isValidityStateNew = false
		healthCertificateService.healthCertifiedPersons.first?.healthCertificates.first?.isNew = false

		waitForExpectations(timeout: .medium)

		requestsSubscription.cancel()
		personsSubscription.cancel()
		countSubscription.cancel()

		XCTAssertEqual(
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = healthCertificateService.$healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = healthCertificateService.$healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = healthCertificateService.$healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
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

		let appConfig = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.first, testCertificateRequest)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let personsExpectation = expectation(description: "Persons not empty")
		personsExpectation.expectedFulfillmentCount = 3
		let personsSubscription = healthCertificateService.$healthCertifiedPersons
			.sink {
				if !$0.isEmpty {
					personsExpectation.fulfill()
				}
			}

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.first, testCertificateRequest)
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

		let appConfig = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.first, testCertificateRequest)
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

		let appConfig = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.first, testCertificateRequest)
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

		let appConfig = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "completion called")
		healthCertificateRequestService.executeTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.first, testCertificateRequest)
		XCTAssertTrue(testCertificateRequest.requestExecutionFailed)
		XCTAssertFalse(testCertificateRequest.isLoading)
	}

	func testTestCertificateExecution_PCRAndNoLabId_dgcNotSupportedByLabErrorReturned() {
		let store = MockTestStore()
		let appConfig = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: ClientMock(),
			appConfiguration: appConfig,
			healthCertificateService: healthCertificateService
		)

		let completionExpectation = expectation(description: "Completion is called.")
		healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
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
		
		XCTAssertEqual(healthCertificateRequestService.testCertificateRequests.count, 1)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests[0].requestExecutionFailed)
		XCTAssertFalse(healthCertificateRequestService.testCertificateRequests[0].isLoading)
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let requestsSubscription = healthCertificateRequestService.$testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let completionExpectation = expectation(description: "registerAndExecuteTestCertificateRequest completion called")
		healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
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
			try XCTUnwrap(healthCertificateService.healthCertifiedPersons.first).healthCertificates.first?.base45,
			base45TestCertificate
		)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
	}

	func testTestCertificateRegistrationAndExecution_MaxPersonCountNotConsideredOnRegistration() throws {
		let client = ClientMock()

		var keyPair: DCCRSAKeyPair?

		let getDigitalCovid19CertificateExpectation = expectation(description: "getDigitalCovid19Certificate called")
		client.onGetDigitalCovid19Certificate = { _, _, completion in
			let dek = (try? keyPair?.encrypt(Data()).base64EncodedString()) ?? ""
			getDigitalCovid19CertificateExpectation.fulfill()
			completion(.success((DCCResponse(dek: dek, dcc: "coseObject"))))
		}

		var maxCountFeature = SAP_Internal_V2_AppFeature()
		maxCountFeature.label = "dcc-person-count-max"
		maxCountFeature.value = 1

		var appFeatures = SAP_Internal_V2_AppFeatures()
		appFeatures.appFeatures = [maxCountFeature]

		var config = CachedAppConfigurationMock.defaultAppConfiguration
		config.dgcParameters.testCertificateParameters.waitAfterPublicKeyRegistrationInSeconds = 1
		config.dgcParameters.testCertificateParameters.waitForRetryInSeconds = 1
		config.appFeatures = appFeatures
		let appConfig = CachedAppConfigurationMock(with: config)

		let base45TestCertificate = try base45Fake(
			from: DigitalCovidCertificate.fake(
				dateOfBirth: "1970-03-26",
				testEntries: [TestEntry.fake()]
			)
		)

		var digitalCovidCertificateAccess = MockDigitalCovidCertificateAccess()
		digitalCovidCertificateAccess.convertedToBase45 = .success(base45TestCertificate)

		let store = MockTestStore()
		store.healthCertifiedPersons = [
			HealthCertifiedPerson(
				healthCertificates: [try vaccinationCertificate(dateOfBirth: "1997-06-16")],
				boosterRule: .fake()
			)
		]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let healthCertificateRequestService = HealthCertificateRequestService(
			store: store,
			client: client,
			appConfiguration: appConfig,
			digitalCovidCertificateAccess: digitalCovidCertificateAccess,
			healthCertificateService: healthCertificateService
		)

		let requestsSubscription = healthCertificateRequestService.$testCertificateRequests
			.sink {
				if let requestWithKeyPair = $0.first(where: { $0.rsaKeyPair != nil }) {
					keyPair = requestWithKeyPair.rsaKeyPair
				}
			}

		let completionExpectation = expectation(description: "registerAndExecuteTestCertificateRequest completion called")
		healthCertificateRequestService.registerAndExecuteTestCertificateRequest(
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

		XCTAssertEqual(healthCertificateService.healthCertifiedPersons.count, 2)
		XCTAssertTrue(healthCertificateRequestService.testCertificateRequests.isEmpty)
	}

}
