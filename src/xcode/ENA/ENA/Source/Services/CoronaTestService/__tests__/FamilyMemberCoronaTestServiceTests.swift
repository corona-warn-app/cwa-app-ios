//
// 🦠 Corona-Warn-App
//

@testable import ENA
import OpenCombine
import ExposureNotification
import HealthCertificateToolkit
import XCTest

// swiftlint:disable:next type_body_length
class FamilyMemberCoronaTestServiceTests: CWATestCase {

	// MARK: - Unseen News Count

	func testUnseenNewsCount() {
		let appConfiguration = CachedAppConfigurationMock()
		let client = ClientMock()
		let store = MockTestStore()

		let antigenTest1: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash1", isNew: true, testResultWasShown: true))
		let antigenTest2: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash2", isNew: true, testResultWasShown: false))
		let antigenTest3: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash3", isNew: false, testResultWasShown: true))
		let antigenTest4: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash4", isNew: false, finalTestResultReceivedDate: nil, testResultWasShown: false))
		let antigenTest5: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash5", isNew: false, finalTestResultReceivedDate: Date(), testResultWasShown: false))
		let pcrTest1: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash1", isNew: true, testResultWasShown: true))
		let pcrTest2: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash2", isNew: true, testResultWasShown: false))
		let pcrTest3: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash3", isNew: false, testResultWasShown: true))
		let pcrTest4: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash4", isNew: false, finalTestResultReceivedDate: nil, testResultWasShown: false))
		let pcrTest5: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash5", isNew: false, finalTestResultReceivedDate: Date(), testResultWasShown: false))

		store.familyMemberTests = [antigenTest1, antigenTest2, antigenTest3, antigenTest4, antigenTest5, pcrTest1, pcrTest2, pcrTest3, pcrTest4, pcrTest5]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertEqual(service.unseenNewsCount, 6)

		service.evaluateShowing(of: antigenTest1)
		XCTAssertEqual(service.unseenNewsCount, 5)

		service.evaluateShowing(of: antigenTest2)
		XCTAssertEqual(service.unseenNewsCount, 4)

		service.evaluateShowing(of: antigenTest3)
		XCTAssertEqual(service.unseenNewsCount, 4)

		service.evaluateShowing(of: antigenTest4)
		XCTAssertEqual(service.unseenNewsCount, 4)

		service.evaluateShowing(of: antigenTest5)
		XCTAssertEqual(service.unseenNewsCount, 3)

		service.evaluateShowing(of: pcrTest1)
		XCTAssertEqual(service.unseenNewsCount, 2)

		service.evaluateShowing(of: pcrTest2)
		XCTAssertEqual(service.unseenNewsCount, 1)

		service.evaluateShowing(of: pcrTest3)
		XCTAssertEqual(service.unseenNewsCount, 1)

		service.evaluateShowing(of: pcrTest4)
		XCTAssertEqual(service.unseenNewsCount, 1)

		service.evaluateShowing(of: pcrTest5)
		XCTAssertEqual(service.unseenNewsCount, 0)
	}

	func testEvaluatingShowingAllTests() {
		let appConfiguration = CachedAppConfigurationMock()
		let client = ClientMock()
		let store = MockTestStore()

		let antigenTest1: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash1", isNew: true, testResultWasShown: true))
		let antigenTest2: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash2", isNew: true, testResultWasShown: false))
		let antigenTest3: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash3", isNew: false, testResultWasShown: true))
		let antigenTest4: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash4", isNew: false, finalTestResultReceivedDate: nil, testResultWasShown: false))
		let antigenTest5: FamilyMemberCoronaTest = .antigen(.mock(qrCodeHash: "antigenQRCodeHash5", isNew: false, finalTestResultReceivedDate: Date(), testResultWasShown: false))
		let pcrTest1: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash1", isNew: true, testResultWasShown: true))
		let pcrTest2: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash2", isNew: true, testResultWasShown: false))
		let pcrTest3: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash3", isNew: false, testResultWasShown: true))
		let pcrTest4: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash4", isNew: false, finalTestResultReceivedDate: nil, testResultWasShown: false))
		let pcrTest5: FamilyMemberCoronaTest = .pcr(.mock(qrCodeHash: "pcrQRCodeHash5", isNew: false, finalTestResultReceivedDate: Date(), testResultWasShown: false))

		store.familyMemberTests = [antigenTest1, antigenTest2, antigenTest3, antigenTest4, antigenTest5, pcrTest1, pcrTest2, pcrTest3, pcrTest4, pcrTest5]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertEqual(service.unseenNewsCount, 6)

		service.evaluateShowingAllTests()

		XCTAssertEqual(service.unseenNewsCount, 0)
	}

	// MARK: - Get Registration Token

	func testGIVEN_Service_WHEN_getRegistrationToken_THEN_MallFormattedDOB() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		// WHEN
		let expectation = expectation(description: "mal formatted date of birth")
		service.getRegistrationToken(forKey: "", withType: .qrCode, dateOfBirthKey: "987654321") { result in
			if result == .failure(.malformedDateOfBirthKey) {
				expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	// MARK: - Test Registration

	func testRegisterPCRTestAndGetResult_successWithoutCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(service.coronaTests.value.isEmpty)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			for: "displayName",
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, .pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertEqual(pcrTest.displayName, "displayName")
		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(pcrTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(pcrTest.sampleCollectionDate)
		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
		XCTAssertFalse(pcrTest.testResultWasShown)
		XCTAssertTrue(pcrTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)
		XCTAssertFalse(pcrTest.isOutdated)
		XCTAssertFalse(pcrTest.isLoading)
	}

	func testRegisterPCRTestAndGetResult_successWithCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertEqual(sendModel.keyDob, "xfa760e171f000ef5a7f863ab180f6f6e8185c4890224550395281d839d85458")
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: nil)), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let testsUpdateExpectation = expectation(description: "Corona tests updated")
		testsUpdateExpectation.expectedFulfillmentCount = 7

		let testsSubscription = service.coronaTests
			.sink { _ in
				testsUpdateExpectation.fulfill()
			}

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			for: "displayName",
			guid: "E1277F-E1277F24-4AD2-40BC-AFF8-CBCCCD893E4B",
			qrCodeHash: "qrCodeHash",
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .medium)
		testsSubscription.cancel()

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken2")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(pcrTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertFalse(pcrTest.testResultWasShown)
		XCTAssertTrue(pcrTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(pcrTest.certificateConsentGiven)
		XCTAssertTrue(pcrTest.certificateRequested)
		XCTAssertFalse(pcrTest.isOutdated)
		XCTAssertFalse(pcrTest.isLoading)
	}

	func testRegisterPCRTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: nil)), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			for: "displayName",
			guid: "E1277F-E1277F24-4AD2-40BC-AFF8-CBCCCD893E4B",
			qrCodeHash: "qrCodeHash",
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertTrue(pcrTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)
	}

	func testRegisterPCRTestAndGetResult_RegistrationFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			// the extra load response if for the fakeVerificationServerRequest for PlausibleDeniability
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			for: "displayName",
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertTrue(service.coronaTests.value.isEmpty)
	}

	func testRegisterPCRTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.failure(ServiceError<TestResultError>.unexpectedServerError(500))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			for: "displayName",
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .testResultError(.unexpectedServerError(500)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertEqual(pcrTest.displayName, "displayName")
		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(pcrTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(pcrTest.sampleCollectionDate)
		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
		XCTAssertFalse(pcrTest.testResultWasShown)
		XCTAssertTrue(pcrTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)
		XCTAssertFalse(pcrTest.isOutdated)
		XCTAssertFalse(pcrTest.isLoading)
	}

	func testRegisterAntigenTestAndGetResult_successWithCertificateNotSupported() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .antigen), sc: nil, labId: "SomeLabId"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(service.coronaTests.value.isEmpty)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, .pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.displayName, "displayName")
		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(antigenTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(antigenTest.sampleCollectionDate)
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.testResultWasShown)
		XCTAssertFalse(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(antigenTest.certificateConsentGiven)
		XCTAssertFalse(antigenTest.certificateRequested)
		XCTAssertFalse(antigenTest.isOutdated)
		XCTAssertFalse(antigenTest.isLoading)
	}

	func testRegisterAntigenTestAndGetResult_successWithoutCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken")
				),
				willLoadResource: { resource in
					// Ensure that the date of birth is not passed to the client for antigen tests if it is given accidentally

					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .antigen), sc: nil, labId: "SomeLabId")), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(service.coronaTests.value.isEmpty)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, .pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.displayName, "displayName")
		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(antigenTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(antigenTest.sampleCollectionDate)
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.testResultWasShown)
		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(antigenTest.certificateConsentGiven)
		XCTAssertFalse(antigenTest.certificateRequested)
		XCTAssertFalse(antigenTest.isOutdated)
		XCTAssertFalse(antigenTest.isLoading)
	}

	func testRegisterAntigenTestAndGetResult_successWithCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					// Ensure that the date of birth is not passed to the client for antigen tests if it is given accidentally

					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .antigen), sc: Int(Date(timeIntervalSinceNow: -60).timeIntervalSince1970), labId: "SomeLabId")), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let testsUpdateExpectation = expectation(description: "Corona tests updated")
		testsUpdateExpectation.expectedFulfillmentCount = 7

		let testsSubscription = service.coronaTests
			.sink { _ in
				testsUpdateExpectation.fulfill()
			}

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .medium)
		testsSubscription.cancel()

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.registrationToken, "registrationToken2")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(antigenTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.sampleCollectionDate).timeIntervalSince1970,
			Date(timeIntervalSinceNow: -60).timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.testDate).timeIntervalSince1970,
			Date(timeIntervalSinceNow: -60).timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(antigenTest.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertFalse(antigenTest.testResultWasShown)
		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(antigenTest.certificateConsentGiven)
		XCTAssertTrue(antigenTest.certificateRequested)
		XCTAssertFalse(antigenTest.isOutdated)
		XCTAssertFalse(antigenTest.isLoading)
	}

	func testRegisterAntigenTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .antigen), sc: nil, labId: nil)), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(antigenTest.certificateConsentGiven)
		XCTAssertTrue(antigenTest.certificateRequested)
	}

	func testRegisterAntigenTestAndGetResult_RegistrationFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			// the extra load response if for the fakeVerificationServerRequest for PlausibleDeniability
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertTrue(service.coronaTests.value.isEmpty)
	}

	func testRegisterAntigenTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.failure(ServiceError<TestResultError>.unexpectedServerError(500))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .testResultError(.unexpectedServerError(500)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.displayName, "displayName")
		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(antigenTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(antigenTest.sampleCollectionDate)
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.testResultWasShown)
		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(antigenTest.certificateConsentGiven)
		XCTAssertFalse(antigenTest.certificateRequested)
		XCTAssertFalse(antigenTest.isOutdated)
		XCTAssertFalse(antigenTest.isLoading)
	}

	func testRegisterRapidPCRTestAndGetResult_successWithCertificateNotSupported() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(service.coronaTests.value.isEmpty)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, .pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.coronaTests.value.first else {
			XCTFail("rapidPCRTest should be registered")
			return
		}

		XCTAssertEqual(rapidPCRTest.displayName, "displayName")
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(rapidPCRTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(rapidPCRTest.sampleCollectionDate)
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.testResultWasShown)
		XCTAssertFalse(rapidPCRTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(rapidPCRTest.certificateConsentGiven)
		XCTAssertFalse(rapidPCRTest.certificateRequested)
		XCTAssertFalse(rapidPCRTest.isOutdated)
		XCTAssertFalse(rapidPCRTest.isLoading)
	}

	func testRegisterRapidPCRTestAndGetResult_successWithoutCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken")
				),
				willLoadResource: { resource in
					// Ensure that the date of birth is not passed to the client for antigen tests if it is given accidentally

					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId")), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		XCTAssertTrue(service.coronaTests.value.isEmpty)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, .pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.coronaTests.value.first else {
			XCTFail("rapidPCRTest should be registered")
			return
		}

		XCTAssertEqual(rapidPCRTest.displayName, "displayName")
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(rapidPCRTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(rapidPCRTest.sampleCollectionDate)
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.testResultWasShown)
		XCTAssertTrue(rapidPCRTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(rapidPCRTest.certificateConsentGiven)
		XCTAssertFalse(rapidPCRTest.certificateRequested)
		XCTAssertFalse(rapidPCRTest.isOutdated)
		XCTAssertFalse(rapidPCRTest.isLoading)
	}

	func testRegisterRapidPCRTestAndGetResult_successWithCertificateConsentGiven() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					// Ensure that the date of birth is not passed to the client for antigen tests if it is given accidentally

					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: "SomeLabId")), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let testsUpdateExpectation = expectation(description: "Corona tests updated")
		testsUpdateExpectation.expectedFulfillmentCount = 7

		let testsSubscription = service.coronaTests
			.sink { _ in
				testsUpdateExpectation.fulfill()
			}

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .medium)
		testsSubscription.cancel()

		guard let rapidPCRTest = service.coronaTests.value.first else {
			XCTFail("rapidPCRTest should be registered")
			return
		}

		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken2")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(rapidPCRTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(rapidPCRTest.sampleCollectionDate)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(rapidPCRTest.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertFalse(rapidPCRTest.testResultWasShown)
		XCTAssertTrue(rapidPCRTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(rapidPCRTest.certificateConsentGiven)
		XCTAssertTrue(rapidPCRTest.certificateRequested)
		XCTAssertFalse(rapidPCRTest.isOutdated)
		XCTAssertFalse(rapidPCRTest.isLoading)
	}

	func testRegisterRapidPCRTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken2")
				),
				willLoadResource: { resource in
					guard let resource = resource as? TeleTanResource,
						let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: nil)), willLoadResource: nil)
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			resultExpectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.coronaTests.value.first else {
			XCTFail("rapidPCRTest should be registered")
			return
		}

		XCTAssertTrue(rapidPCRTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(rapidPCRTest.certificateConsentGiven)
		XCTAssertTrue(rapidPCRTest.certificateRequested)
	}

	func testRegisterRapidPCRTestAndGetResult_RegistrationFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			// the extra load response if for the fakeVerificationServerRequest for PlausibleDeniability
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertTrue(service.coronaTests.value.isEmpty)
	}

	func testRegisterRapidPCRTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let store = MockTestStore()
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.failure(ServiceError<TestResultError>.unexpectedServerError(500))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .testResultError(.unexpectedServerError(500)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.coronaTests.value.first else {
			XCTFail("rapidPCRTest should be registered")
			return
		}

		XCTAssertEqual(rapidPCRTest.displayName, "displayName")
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertTrue(rapidPCRTest.isNew)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.testDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertNil(rapidPCRTest.sampleCollectionDate)
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.testResultWasShown)
		XCTAssertTrue(rapidPCRTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(rapidPCRTest.certificateConsentGiven)
		XCTAssertFalse(rapidPCRTest.certificateRequested)
		XCTAssertFalse(rapidPCRTest.isOutdated)
		XCTAssertFalse(rapidPCRTest.isLoading)
	}

	// MARK: - Outdated State

	func testRegisterAlreadyOutdatedNegativeAntigenTestWithoutSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .antigen), sc: nil, labId: "SomeLabId"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let publisherExpectation = expectation(description: "corona tests published")
		publisherExpectation.expectedFulfillmentCount = 8

		let subscription = service.coronaTests
			.sink { _ in
				publisherExpectation.fulfill()
			}

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { _ in
			resultExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
		subscription.cancel()

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertTrue(antigenTest.isOutdated)
	}

	func testRegisterAlreadyOutdatedNegativeAntigenTestWithSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.success(TestResultReceiveModel(
				testResult: TestResult.serverResponse(
					for: .negative, on: .antigen),
				sc: Int(Date(timeIntervalSinceNow: -(60 * 60 * 48)).timeIntervalSince1970),
				labId: "SomeLabId"
			))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let publisherExpectation = expectation(description: "corona tests published")
		publisherExpectation.expectedFulfillmentCount = 8

		let subscription = service.coronaTests
			.sink { _ in
				publisherExpectation.fulfill()
			}

		let resultExpectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			for: "displayName",
			with: "hash",
			qrCodeHash: "qrCodeHash",
			// Outdated only according to sample collection date, not according to point of care consent date
			// As we are using the sample collection date if set, the test is outdated
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 46)),
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { _ in
			resultExpectation.fulfill()
		}

		waitForExpectations(timeout: .medium)
		subscription.cancel()

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertTrue(antigenTest.isOutdated)
	}

	func testOutdatedStateIsSetForNegativeAntigenTestWithoutSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			sampleCollectionDate: nil,
			registrationToken: "regToken",
			qrCodeHash: "antigenQRCodeHash",
			testResult: .negative
		))
		store.familyMemberTests = [antigenTest]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let publisherExpectation = expectation(description: "corona tests published")

		let subscription = service.coronaTests
			.sink { _ in
				publisherExpectation.fulfill()
			}

		waitForExpectations(timeout: .short)
		subscription.cancel()

		guard let antigenTest = service.upToDateTest(for: antigenTest) else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertTrue(antigenTest.isOutdated)
	}

	func testOutdatedStateIsSetForNegativeAntigenTestWithSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		// Outdated only according to sample collection date, not according to point of care consent date
		// As we are using the sample collection date if set, the test is outdated
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 46)),
			sampleCollectionDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			registrationToken: "regToken",
			qrCodeHash: "antigenQRCodeHash",
			testResult: .negative
		))
		store.familyMemberTests = [antigenTest]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let publisherExpectation = expectation(description: "corona tests published")

		let subscription = service.coronaTests
			.sink { _ in
				publisherExpectation.fulfill()
			}

		waitForExpectations(timeout: .short)
		subscription.cancel()

		guard let antigenTest = service.upToDateTest(for: antigenTest) else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertTrue(antigenTest.isOutdated)
	}

	func testOutdatedStateIsSetForNegativeAntigenTestBecomingOutdatedAfter5And10Seconds() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let antigenTest1: FamilyMemberCoronaTest = .antigen(.mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48) + 5),
			sampleCollectionDate: nil,
			registrationToken: "regToken",
			qrCodeHash: "antigenQRCodeHash",
			testResult: .negative
		))
		let antigenTest2: FamilyMemberCoronaTest = .antigen(.mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48) + 10),
			sampleCollectionDate: nil,
			registrationToken: "regToken2",
			qrCodeHash: "antigenQRCodeHash2",
			testResult: .negative
		))
		store.familyMemberTests = [antigenTest1, antigenTest2]

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let publisherExpectation = expectation(description: "corona tests published")
		publisherExpectation.expectedFulfillmentCount = 3

		let subscription = service.coronaTests
			.sink { _ in
				publisherExpectation.fulfill()
			}

		// Setting 20 seconds explicitly as it takes 5 and 10 seconds for the outdated state to happen
		waitForExpectations(timeout: 20)
		subscription.cancel()

		guard let antigenTest1 = service.upToDateTest(for: antigenTest1), let antigenTest2 = service.upToDateTest(for: antigenTest2) else {
			XCTFail("antigenTests should be registered")
			return
		}

		XCTAssertTrue(antigenTest1.isOutdated)
		XCTAssertTrue(antigenTest2.isOutdated)
	}

	func testOutdatedStateIsNotSetForNonNegativeAntigenTests() {
		let testResults: [TestResult] = [.pending, .positive, .invalid, .expired]
		for testResult in testResults {
			var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
			defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
			let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

			let client = ClientMock()
			let store = MockTestStore()

			let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(
				pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
				sampleCollectionDate: nil,
				registrationToken: "regToken",
				qrCodeHash: "antigenQRCodeHash",
				testResult: testResult
			))
			store.familyMemberTests = [antigenTest]

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake()
			)

			let service = FamilyMemberCoronaTestService(
				client: client,
				store: store,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					client: client,
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				recycleBin: .fake()
			)

			let publisherExpectation = expectation(description: "corona tests published")

			let subscription = service.coronaTests
				.sink { _ in
					publisherExpectation.fulfill()
				}

			waitForExpectations(timeout: .short)
			subscription.cancel()

			guard let antigenTest = service.upToDateTest(for: antigenTest) else {
				XCTFail("antigenTest should be registered")
				return
			}

			XCTAssertFalse(antigenTest.isOutdated)
		}
	}

	// MARK: - Test Result Update

	func testUpdatePCRTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .pcr), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		service.coronaTests.value = [pcrTest]

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: pcrTest) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testUpdateAntigenTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .antigen), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		service.coronaTests.value = [antigenTest]

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: antigenTest) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testUpdateTestResult_noCoronaTestOfRequestedType() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		service.coronaTests.value = []

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: pcrTest) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noCoronaTestOfRequestedType)
			case .success:
				XCTFail("This test should always fail since the test is not registered.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdatePCRTestResult_noRegistrationToken() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: nil, qrCodeHash: "pcrQRCodeHash"))
		service.coronaTests.value = [pcrTest]

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: pcrTest) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.coronaTests.value.first else {
			XCTFail("pcrTest should be registered")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
	}

	func testUpdateAntigenTestResult_noRegistrationToken() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: nil, qrCodeHash: "pcrQRCodeHash"))
		service.coronaTests.value = [antigenTest]

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: antigenTest) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.coronaTests.value.first else {
			XCTFail("antigenTest should be registered")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
	}

	func test_When_UpdatePresentNotificationTrue_Then_NotificationShouldBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake")),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			notificationCenter: mockNotificationCenter,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")
		completionExpectation.expectedFulfillmentCount = 3

		service.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}

		// Updating two more times to check that notification are only scheduled once
		service.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}

		service.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
	}

	func test_When_UpdatePresentNotificationFalse_Then_NotificationShouldNOTBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .pcr), sc: nil, labId: "SomeLabId")),
			.success(TeleTanReceiveModel(registrationToken: "token"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")
		service.updateTestResults(presentNotification: false) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultsFails_Then_ErrorIsReturned() {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.invalidResponse),
			.success(TeleTanReceiveModel(registrationToken: "token"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")
		service.updateTestResults(presentNotification: true) { result in
			if case .success = result {
				XCTFail("Success not expected")
			}
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateTestResultsSuccessWithPending_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .antigen), sc: nil, labId: "SomeLabId"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")
		service.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultsSuccessWithExpired_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .pcr), sc: nil, labId: "SomeLabId")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .antigen), sc: nil, labId: "SomeLabId"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")
		service.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_Update_And_FinalTestResultExist_Then_ClientIsNotCalled() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .pcr), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				})
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", finalTestResultReceivedDate: Date()))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash", finalTestResultReceivedDate: Date()))

		service.coronaTests.value = [pcrTest, antigenTest]

		service.updateTestResults(presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_Update_And_NoFinalTestResultExist_Then_ClientIsCalled() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .pcr), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				}),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .antigen), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				})
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", finalTestResultReceivedDate: nil))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash", finalTestResultReceivedDate: nil))

		service.coronaTests.value = [pcrTest, antigenTest]

		service.updateTestResults(presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultOlderThan21Days_Then_ClientIsNotCalled() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -21, to: Date()))

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .pcr), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				}),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .antigen), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				})
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .expired))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash", testResult: .expired))

		service.coronaTests.value = [pcrTest, antigenTest]

		service.updateTestResults(presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultYoungerThan21Days_Then_ClientIsCalled() throws {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let dateComponents = DateComponents(day: -21, second: 10)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .pcr), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				}),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .antigen), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				})
		])

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .expired))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash", testResult: .expired))

		service.coronaTests.value = [pcrTest, antigenTest]

		service.updateTestResults(presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))

		service.coronaTests.value = [pcrTest]

		let completionExpectation = expectation(description: "Completion should be called.")

		service.updateTestResult(for: pcrTest, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(service.coronaTests.value.first?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))

		service.coronaTests.value = [pcrTest]

		let completionExpectation = expectation(description: "Completion should be called.")

		service.updateTestResult(for: pcrTest, presentNotification: false) {
			XCTAssertEqual($0, .failure(.testResultError(.receivedResourceError(.qrDoesNotExist))))
			XCTAssertEqual(service.coronaTests.value.first?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))
		// Set point of care date to younger than 21 days to ensure that registration date wins
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(pointOfCareConsentDate: pointOfCareConsentDate, registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))

		service.coronaTests.value = [antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")

		service.updateTestResult(for: antigenTest, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(service.coronaTests.value.first?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))
		// Set point of care date to older than 21 days to ensure that registration date wins
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(pointOfCareConsentDate: pointOfCareConsentDate, registrationDate: registrationDate, registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash", testResult: .negative))

		service.coronaTests.value = [antigenTest]

		let completionExpectation = expectation(description: "Completion should be called.")

		service.updateTestResult(for: antigenTest, presentNotification: false) {
			XCTAssertEqual($0, .failure(.testResultError(.receivedResourceError(.qrDoesNotExist))))
			XCTAssertEqual(service.coronaTests.value.first?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	// MARK: - Test Removal

	func testMovingCoronaTestToBin() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let recycleBin = RecycleBin(store: store)

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: recycleBin
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: recycleBin
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let pcrTest2: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken2", qrCodeHash: "pcrQRCodeHash2"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		XCTAssertTrue(store.recycleBinItems.isEmpty)
		XCTAssertTrue(store.recycleBinItemsSubject.value.isEmpty)

		service.moveTestToBin(pcrTest)

		XCTAssertEqual(service.coronaTests.value, [antigenTest])
		XCTAssertEqual(store.recycleBinItems.count, 1)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 1)

		service.reregister(coronaTest: pcrTest2)

		XCTAssertEqual(service.coronaTests.value, [antigenTest, pcrTest2])

		service.moveTestToBin(antigenTest)

		XCTAssertEqual(service.coronaTests.value, [pcrTest2])
		XCTAssertEqual(store.recycleBinItems.count, 2)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 2)

		service.moveTestToBin(pcrTest2)

		XCTAssertEqual(service.coronaTests.value, [])
		XCTAssertEqual(store.recycleBinItems.count, 3)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 3)
	}

	func testDeletingCoronaTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		let pcrTest: FamilyMemberCoronaTest = .pcr(.mock(registrationToken: "regToken", qrCodeHash: "pcrQRCodeHash"))
		let antigenTest: FamilyMemberCoronaTest = .antigen(.mock(registrationToken: "regToken", qrCodeHash: "antigenQRCodeHash"))

		service.coronaTests.value = [pcrTest, antigenTest]

		service.removeTest(pcrTest)

		XCTAssertEqual(service.coronaTests.value, [antigenTest])

		service.reregister(coronaTest: pcrTest)

		XCTAssertEqual(service.coronaTests.value, [antigenTest, pcrTest])

		service.removeTest(antigenTest)

		XCTAssertEqual(service.coronaTests.value, [pcrTest])

		service.removeTest(pcrTest)

		XCTAssertEqual(service.coronaTests.value, [])
	}

	// MARK: - Plausible Deniability

	func test_getTestResultPlaybookPositive() throws {
		try getTestResultPlaybookTest(for: .pcr, with: .positive)
		try getTestResultPlaybookTest(for: .antigen, with: .positive)
	}

	func test_getTestResultPlaybookNegative() throws {
		try getTestResultPlaybookTest(for: .pcr, with: .negative)
		try getTestResultPlaybookTest(for: .antigen, with: .negative)
	}

	func test_getTestResultPlaybookPending() throws {
		try getTestResultPlaybookTest(for: .pcr, with: .pending)
		try getTestResultPlaybookTest(for: .antigen, with: .pending)
	}

	func test_getTestResultPlaybookInvalid() throws {
		try getTestResultPlaybookTest(for: .pcr, with: .invalid)
		try getTestResultPlaybookTest(for: .antigen, with: .invalid)
	}

	func test_getTestResultPlaybookExpired() throws {
		try getTestResultPlaybookTest(for: .pcr, with: .expired)
		try getTestResultPlaybookTest(for: .antigen, with: .expired)
	}

	// MARK: - Private

	private func getTestResultPlaybookTest(for coronaTestType: CoronaTestType, with testResult: TestResult) throws {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let client = ClientMock()

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: testResult, on: coronaTestType), sc: nil, labId: nil)),
				willLoadResource: { resource in
					guard let resource = resource as? TestResultResource  else {
						XCTFail("TestResultResource expected.")
						return
					}
					expectation.fulfill()
					XCTAssertFalse(resource.locator.isFake)
					XCTAssertEqual(count, 0)
					count += 1
				}
			),
			LoadResource(
				result: .success(
					RegistrationTokenReceiveModel(submissionTAN: "fake")
				),
				willLoadResource: { resource in
					guard let resource = resource as? RegistrationTokenResource  else {
						XCTFail("RegistrationTokenResource expected.")
						return
					}
					expectation.fulfill()

					XCTAssertTrue(resource.locator.isFake)
					XCTAssertEqual(count, 1)
					count += 1
				})
		])
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)

		let service = FamilyMemberCoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: .fake()
		)

		switch coronaTestType {
		case .pcr:
			service.coronaTests.value = [.pcr(.mock(registrationToken: "regToken"))]
		case .antigen:
			service.coronaTests.value = [.antigen(.mock(registrationToken: "regToken"))]
		}

		// Run test.

		service.updateTestResult(for: try XCTUnwrap(service.coronaTests.value.first)) { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let result):
				XCTAssertEqual(result, testResult)
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	// swiftlint:disable:next file_length
}
