//
// 🦠 Corona-Warn-App
//

@testable import ENA
import OpenCombine
import ExposureNotification
import HealthCertificateToolkit
import XCTest

// swiftlint:disable:next type_body_length
class CoronaTestServiceTests: CWATestCase {

	func testGIVEN_Service_WHEN_getRegistrationToken_THEN_MallFormattedDOB() {
		// GIVEN
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		// WHEN
		let expectation = expectation(description: "mal formatted date of birth")
		service.getRegistrationToken(forKey: "", withType: .teleTan, dateOfBirthKey: "987654321") { result in
			if result == .failure(.malformedDateOfBirthKey) {
				expectation.fulfill()
			}
		}

		// THEN
		waitForExpectations(timeout: .short)
	}

	func testOutdatedPublisherSetForAlreadyOutdatedNegativeAntigenTestWithoutSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)

		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		service.antigenTest.value = .mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			sampleCollectionDate: nil,
			testResult: .negative
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherSetForAlreadyOutdatedNegativeAntigenTestWithSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		// Outdated only according to sample collection date, not according to point of care consent date
		// As we are using the sample collection date if set, the test is outdated
		service.antigenTest.value = .mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 46)),
			sampleCollectionDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			testResult: .negative
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherSetForNegativeAntigenTestBecomingOutdatedAfter5Seconds() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		service.antigenTest.value = .mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48) + 5),
			testResult: .negative
		)

		// Setting 10 seconds explicitly as it takes 5 seconds for the outdated state to happen
		waitForExpectations(timeout: 10)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherResetWhenRemovingNegativeAntigenTest() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 4

		let expectedValues = [false, false, true, false]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Remove test as soon as outdated state is set
				if antigenTestIsOutdated {
					service.removeTest(.antigen)
				}
			}

		service.antigenTest.value = .mock(
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			testResult: .negative
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherResetWhenReplacingOutdatedNegativeAntigenTest() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 4

		let expectedValues = [false, false, true, false]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Replace test as soon as outdated state is set
				if antigenTestIsOutdated && service.antigenTest.value?.registrationToken == "1" {
					service.antigenTest.value = .mock(
						registrationToken: "2",
						pointOfCareConsentDate: Date(),
						testResult: .pending
					)
				}
			}

		service.antigenTest.value = .mock(
			registrationToken: "1",
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			testResult: .negative
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherStillOutdatedWhenReplacingOutdatedNegativeAntigenTestWithAnotherOutdatedOne() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let store = MockTestStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 5

		let expectedValues = [false, false, true, false, true]

		var receivedValues = [Bool]()
		let subscription = service.antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Replace test as soon as outdated state is set
				if antigenTestIsOutdated && service.antigenTest.value?.registrationToken == "1" {
					service.antigenTest.value = .mock(
						registrationToken: "2",
						pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
						testResult: .negative
					)
				}
			}

		service.antigenTest.value = .mock(
			registrationToken: "1",
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
			testResult: .negative
		)

		waitForExpectations(timeout: .short)

		XCTAssertEqual(receivedValues, expectedValues)

		subscription.cancel()
	}

	func testOutdatedPublisherNotSetForNonNegativeAntigenTests() {
		let testResults: [TestResult] = [.pending, .positive, .invalid, .expired]
		for testResult in testResults {
			var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
			defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
			let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

				let store = MockTestStore()

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake(),
				revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
			)

			let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
			let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
			
			let service = CoronaTestService(
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					restServiceProvider: RestServiceProviderStub(),
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				ppacService: ppacService,
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			let publisherExpectation = expectation(description: "")
			publisherExpectation.expectedFulfillmentCount = 2

			let expectedValues = [false, false]

			var receivedValues = [Bool]()
			let subscription = service.antigenTestIsOutdated
				.sink {
					receivedValues.append($0)
					publisherExpectation.fulfill()
				}

			service.antigenTest.value = .mock(
				pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
				testResult: testResult
			)

			waitForExpectations(timeout: .short)

			XCTAssertEqual(receivedValues, expectedValues)

			subscription.cancel()
		}
	}

	func testCoronaTestOfType() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		XCTAssertNil(service.coronaTest(ofType: .pcr))
		XCTAssertNil(service.coronaTest(ofType: .antigen))

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest.value = .mock(registrationToken: "antigenRegistrationToken")

		XCTAssertEqual(service.coronaTest(ofType: .pcr)?.registrationToken, "pcrRegistrationToken")
		XCTAssertEqual(service.coronaTest(ofType: .antigen)?.registrationToken, "antigenRegistrationToken")
	}

	// MARK: - Test Registration

	func testRegisterPCRTestAndGetResult_successWithoutSubmissionOrCertificateConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: "SomeLabId"))

		])


		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
		XCTAssertFalse(pcrTest.positiveTestResultWasShown)
		XCTAssertFalse(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertFalse(pcrTest.journalEntryCreated)
		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)

		XCTAssertEqual(store.pcrTestResultMetadata?.testResult, .pending)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterPCRTestAndGetResult_successWithSubmissionAndCertificateConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()
		
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

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


		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: badgeWrapper
		)

		let expectedCounts = [nil, "1", nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 3
		var receivedCounts = [String?]()

		let countSubscription = badgeWrapper.$stringValue
			.sink { stringValue in
				receivedCounts.append(stringValue)
				countExpectation.fulfill()
			}

		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "E1277F-E1277F24-4AD2-40BC-AFF8-CBCCCD893E4B",
			qrCodeHash: "qrCodeHash",
			isSubmissionConsentGiven: true,
			markAsUnseen: true,
			certificateConsent: .given(dateOfBirth: "2000-01-01")
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		badgeWrapper.reset(.unseenTests)

		waitForExpectations(timeout: .short)
		countSubscription.cancel()
		
		service.createCoronaTestEntryInContactDiary(coronaTestType: .pcr)
		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertTrue(pcrTest.journalEntryCreated)
		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertEqual(pcrTest.registrationToken, "registrationToken2")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
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
		XCTAssertFalse(pcrTest.positiveTestResultWasShown)
		XCTAssertTrue(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertTrue(pcrTest.certificateConsentGiven)
		XCTAssertTrue(pcrTest.certificateRequested)

		XCTAssertEqual(store.pcrTestResultMetadata?.testResult, .negative)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterPCRTestAndGetResult_CertificateConsentGivenWithDateOfBirth() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

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
					XCTAssertEqual(sendModel.keyDob, "x4a7788ef394bc7d52112014b127fe2bf142c51fe1bbb385214280e9db670193")
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: nil)), willLoadResource: nil)
		])


		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)

		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		
		let expectedCounts: [String?] = [nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 1
		var receivedCounts = [String?]()

		let countSubscription = badgeWrapper.$stringValue
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915",
			qrCodeHash: "",
			isSubmissionConsentGiven: true,
			markAsUnseen: false,
			certificateConsent: .given(dateOfBirth: "1995-06-07")
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		countSubscription.cancel()

		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertTrue(pcrTest.certificateConsentGiven)
		XCTAssertTrue(pcrTest.certificateRequested)
	}

	func testRegisterPCRTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

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


		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915",
			qrCodeHash: "",
			isSubmissionConsentGiven: true,
			markAsUnseen: false,
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)
	}

	func testRegisterPCRTestAndGetResult_RegistrationFails() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			// the extra load response if for the fakeVerificationServerRequest for PlausibleDeniability
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])


		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
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

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNil(store.pcrTestResultMetadata)
	}

	func testRegisterPCRTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.failure(
				ServiceError<TestResultError>.unexpectedServerError(500)
			),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])


		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
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

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(pcrTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
		XCTAssertFalse(pcrTest.positiveTestResultWasShown)
		XCTAssertFalse(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertFalse(pcrTest.journalEntryCreated)
		XCTAssertNil(store.pcrTestResultMetadata?.testResult)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterPCRTestWithTeleTAN_successWithoutSubmissionConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		let checkInMock = Checkin.mock()
		let eventStore = MockEventStore()
		eventStore.createCheckin(checkInMock)

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: eventStore,
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		Analytics.setupMock(
			store: store,
			coronaTestService: service
		)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTest(
			teleTAN: "tele-tan",
			isSubmissionConsentGiven: false
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success:
				break
			}
		}
		
		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertTrue(pcrTest.positiveTestResultWasShown)
		XCTAssertFalse(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertTrue(pcrTest.journalEntryCreated)
		XCTAssertFalse(diaryStore.coronaTests.isEmpty)
	}

	func testRegisterPCRTestWithTeleTAN_successWithSubmissionConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken2")
			),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])


		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTest(
			teleTAN: "tele-tan",
			isSubmissionConsentGiven: true
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success:
				break
			}
		}
		
		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.registrationToken, "registrationToken2")
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(pcrTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertTrue(pcrTest.positiveTestResultWasShown)
		XCTAssertTrue(pcrTest.isSubmissionConsentGiven)
		XCTAssertNil(pcrTest.submissionTAN)
		XCTAssertFalse(pcrTest.keysSubmitted)
		XCTAssertTrue(pcrTest.journalEntryCreated)
		XCTAssertFalse(diaryStore.coronaTests.isEmpty)
	}

	func testRegisterPCRTestWithTeleTAN_RegistrationFails() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.teleTanAlreadyUsed)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTest(
			teleTAN: "tele-tan",
			isSubmissionConsentGiven: true
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(.receivedResourceError(.teleTanAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNil(store.pcrTestResultMetadata)
		XCTAssertTrue(diaryStore.coronaTests.isEmpty)
	}

	func testRegisterAntigenTestAndGetResult_successWithoutSubmissionConsentGivenWithTestedPerson() {
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
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .antigen), sc: 123456789, labId: "SomeLabId")), willLoadResource: nil)
		])


		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: true,
			// Date of birth given even though it is not used for antigen tests
			certificateConsent: .given(dateOfBirth: "1964-08-12")
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(antigenTest.pointOfCareConsentDate, Date(timeIntervalSince1970: 2222))
		XCTAssertEqual(antigenTest.testedPerson.firstName, "Erika")
		XCTAssertEqual(antigenTest.testedPerson.lastName, "Mustermann")
		XCTAssertEqual(antigenTest.testedPerson.dateOfBirth, "1964-08-12")
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertEqual(antigenTest.sampleCollectionDate, Date(timeIntervalSince1970: 123456789))
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.positiveTestResultWasShown)
		XCTAssertFalse(antigenTest.isSubmissionConsentGiven)
		XCTAssertNil(antigenTest.submissionTAN)
		XCTAssertFalse(antigenTest.keysSubmitted)
		XCTAssertFalse(antigenTest.journalEntryCreated)
		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(antigenTest.certificateConsentGiven)
		XCTAssertFalse(antigenTest.certificateRequested)
	}

	func testRegisterAntigenTestAndGetResult_successWithSubmissionConsentGiven() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .antigen), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])


		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: badgeWrapper
		)
		
		let expectedCounts = [nil, "1", nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 3
		var receivedCounts = [String?]()
		let countSubscription = badgeWrapper.$stringValue
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}
		
		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			markAsUnseen: true,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		badgeWrapper.reset(.unseenTests)

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}

		countSubscription.cancel()

		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(antigenTest.pointOfCareConsentDate, Date(timeIntervalSince1970: 2222))
		XCTAssertNil(antigenTest.testedPerson.firstName)
		XCTAssertNil(antigenTest.testedPerson.lastName)
		XCTAssertNil(antigenTest.testedPerson.dateOfBirth)
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.positiveTestResultWasShown)
		XCTAssertTrue(antigenTest.isSubmissionConsentGiven)
		XCTAssertNil(antigenTest.submissionTAN)
		XCTAssertFalse(antigenTest.keysSubmitted)
		XCTAssertFalse(antigenTest.journalEntryCreated)
		XCTAssertNil(antigenTest.sampleCollectionDate)
		XCTAssertFalse(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertFalse(antigenTest.certificateConsentGiven)
		XCTAssertFalse(antigenTest.certificateRequested)
	}

	func testRegisterAntigenTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken")
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
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .antigen), sc: nil, labId: nil)), willLoadResource: nil
			)
		])


		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		
		let expectedCounts: [String?] = [nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 1
		var receivedCounts = [String?]()
		let countSubscription = badgeWrapper.$stringValue
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}

		countSubscription.cancel()

		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertTrue(antigenTest.certificateSupportedByPointOfCare)
		XCTAssertTrue(antigenTest.certificateConsentGiven)
		XCTAssertTrue(antigenTest.certificateRequested)
	}

	func testRegisterAntigenTestAndGetResult_RegistrationFails() {

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.antigenTest.value)
	}

	func testRegisterAntigenTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.failure(ServiceError<TestResultError>.unexpectedServerError(500)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		]
		)

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: false,
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

		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.registrationToken, "registrationToken")
		XCTAssertEqual(antigenTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(antigenTest.pointOfCareConsentDate, Date(timeIntervalSince1970: 2222))
		XCTAssertNil(antigenTest.testedPerson.firstName)
		XCTAssertNil(antigenTest.testedPerson.lastName)
		XCTAssertNil(antigenTest.testedPerson.dateOfBirth)
		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
		XCTAssertFalse(antigenTest.positiveTestResultWasShown)
		XCTAssertTrue(antigenTest.isSubmissionConsentGiven)
		XCTAssertNil(antigenTest.submissionTAN)
		XCTAssertFalse(antigenTest.keysSubmitted)
		XCTAssertFalse(antigenTest.journalEntryCreated)
	}

	func testRegisterRapidPCRTestAndGetResult_successWithoutSubmissionConsentGivenWithTestedPerson() {
		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken")
				),
				willLoadResource: { resource in
					// Ensure that the date of birth is not passed to the client for rapid PCR tests if it is given accidentally

					guard let resource = resource as? TeleTanResource,
						  let sendModel = resource.sendResource.sendModel else {
						XCTFail("TeleTanResource expected.")
						return
					}
					XCTAssertNil(sendModel.keyDob)
				}
			),
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: 123456789, labId: "SomeLabId")), willLoadResource: nil)
		])


		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: true,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.pcrTest.value else {
			XCTFail("rapidPCRTest should not be nil")
			return
		}
		
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.positiveTestResultWasShown)
		XCTAssertFalse(rapidPCRTest.isSubmissionConsentGiven)
		XCTAssertNil(rapidPCRTest.submissionTAN)
		XCTAssertFalse(rapidPCRTest.keysSubmitted)
		XCTAssertFalse(rapidPCRTest.journalEntryCreated)
		XCTAssertFalse(rapidPCRTest.certificateConsentGiven)
		XCTAssertFalse(rapidPCRTest.certificateRequested)
		XCTAssertEqual(store.pcrTestResultMetadata?.testResult, .pending)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterRapidPCRTestAndGetResult_successWithSubmissionConsentGiven() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				TeleTanReceiveModel(registrationToken: "registrationToken")
			),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .pending, on: .pcr), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])


		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: badgeWrapper
		)

		let expectedCounts = [nil, "1", nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 3
		var receivedCounts = [String?]()
		let countSubscription = badgeWrapper.$stringValue
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")
		service.registerRapidPCRTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			markAsUnseen: true,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
			}
		}

		badgeWrapper.reset(.unseenTests)

		waitForExpectations(timeout: .short)

		guard let rapidPCRTest = service.pcrTest.value else {
			XCTFail("rapidPCRTest should not be nil")
			return
		}

		countSubscription.cancel()

		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.positiveTestResultWasShown)
		XCTAssertTrue(rapidPCRTest.isSubmissionConsentGiven)
		XCTAssertNil(rapidPCRTest.submissionTAN)
		XCTAssertFalse(rapidPCRTest.keysSubmitted)
		XCTAssertFalse(rapidPCRTest.journalEntryCreated)
		XCTAssertFalse(rapidPCRTest.certificateConsentGiven)
		XCTAssertFalse(rapidPCRTest.certificateRequested)
		
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(store.pcrTestResultMetadata?.testResult, .pending)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testRegisterRapidPCRTestAndGetResult_CertificateConsentGivenWithoutDateOfBirth() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					TeleTanReceiveModel(registrationToken: "registrationToken")
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
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .negative, on: .pcr), sc: nil, labId: nil)), willLoadResource: nil
			)
		])


		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let expectedCounts: [String?] = [nil]
		let countExpectation = expectation(description: "Count updated")
		countExpectation.expectedFulfillmentCount = 1
		var receivedCounts = [String?]()
		let countSubscription = badgeWrapper.$stringValue
			.sink {
				receivedCounts.append($0)
				countExpectation.fulfill()
			}

		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: true,
			certificateConsent: .given(dateOfBirth: nil)
		) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.negative)
			}
		}

		waitForExpectations(timeout: .short)

		guard let rapidPCR = service.pcrTest.value else {
			XCTFail("rapidPCR should not be nil")
			return
		}

		countSubscription.cancel()

		XCTAssertEqual(receivedCounts, expectedCounts)
		XCTAssertTrue(rapidPCR.certificateConsentGiven)
		XCTAssertTrue(rapidPCR.certificateRequested)
	}

	func testRegisterRapidPCRTestAndGetResult_RegistrationFails() {

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .teleTanError(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.pcrTest.value)
	}

	func testRegisterRapidPCRTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TeleTanReceiveModel(registrationToken: "registrationToken")),
			.failure(ServiceError<TestResultError>.unexpectedServerError(500)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		]
		)

		let store = MockTestStore()
		store.enfRiskCalculationResult = .fake()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerRapidPCRTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: false,
			markAsUnseen: false,
			certificateSupportedByPointOfCare: false,
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

		guard let rapidPCRTest = service.pcrTest.value else {
			XCTFail("rapidPCRTest should not be nil")
			return
		}
		
		XCTAssertEqual(rapidPCRTest.registrationToken, "registrationToken")
		XCTAssertEqual(rapidPCRTest.qrCodeHash, "qrCodeHash")
		XCTAssertEqual(
			try XCTUnwrap(rapidPCRTest.registrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
		XCTAssertEqual(rapidPCRTest.testResult, .pending)
		XCTAssertNil(rapidPCRTest.finalTestResultReceivedDate)
		XCTAssertFalse(rapidPCRTest.positiveTestResultWasShown)
		XCTAssertFalse(rapidPCRTest.isSubmissionConsentGiven)
		XCTAssertNil(rapidPCRTest.submissionTAN)
		XCTAssertFalse(rapidPCRTest.keysSubmitted)
		XCTAssertFalse(rapidPCRTest.journalEntryCreated)
		XCTAssertNil(store.pcrTestResultMetadata?.testResult)
		XCTAssertEqual(
			try XCTUnwrap(store.pcrTestResultMetadata?.testRegistrationDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	// MARK: - Test Result Update

	func testUpdatePCRTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .pcr), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = .mock(registrationToken: "regToken")

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(pcrTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}
	
	func testUpdatePCRTestResult_EOL_success_WithPreviousState() {
		// GIVEN
		UserDefaults.standard.setValue(true, forKey: CWAHibernationProvider.isHibernationInUnitTest)
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .pcr), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = .mock(registrationToken: "regToken")

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			UserDefaults.standard.setValue(false, forKey: CWAHibernationProvider.isHibernationInUnitTest)
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return the latest test result before the request.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.pending)
				
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdateAntigenTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .positive, on: .antigen), sc: nil, labId: nil)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = .mock(registrationToken: "regToken")
		
		let expectation = self.expectation(description: "Expect to receive a result.")
		
		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure:
				XCTFail("This test should always return a successful result.")
			case .success(let testResult):
				XCTAssertEqual(testResult, TestResult.positive)
			}
		}
		
		waitForExpectations(timeout: .short)
		
		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}
		
		XCTAssertEqual(antigenTest.testResult, .positive)
		XCTAssertEqual(
			try XCTUnwrap(antigenTest.finalTestResultReceivedDate).timeIntervalSince1970,
			Date().timeIntervalSince1970,
			accuracy: 10
		)
	}

	func testUpdatePCRTestResult_noCoronaTestOfRequestedType() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noCoronaTestOfRequestedType)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdateAntigenTestResult_noCoronaTestOfRequestedType() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noCoronaTestOfRequestedType)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)
	}

	func testUpdatePCRTestResult_noRegistrationToken() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = .mock(registrationToken: nil)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .pcr) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest.value else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
	}

	func testUpdateAntigenTestResult_noRegistrationToken() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest.value = .mock(registrationToken: nil)

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.updateTestResult(for: .antigen) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .noRegistrationToken)
			case .success:
				XCTFail("This test should always fail since the registration token is missing.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest.value else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
	}

	func test_When_UpdatePresentNotificationTrue_Then_NotificationShouldBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		completionExpectation.expectedFulfillmentCount = 3

		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}

		// Updating two more times to check that notification are only scheduled once
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}

		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .extraLong)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
	}

	func test_When_UpdatePresentNotificationFalse_Then_NotificationShouldNOTBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: false) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultsFails_Then_ErrorIsReturned() {

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { result in
			if case .success = result {
				XCTFail("Success not expected")
			}
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .extraLong)
	}

	func test_When_UpdateTestResultsSuccessWithPending_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultSuccessWithPositive_Then_ContactJournalHasAnEntry() throws {
		let sampleCollectionDate = Date()
		let diaryStore = MockDiaryStore()
		let testService = createCoronaTestService(
			forTestResult: .positive,
			sampleCollectionDate: sampleCollectionDate,
			diaryStore: diaryStore
		)
		
		let antigenTest: UserAntigenTest = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -24 * 60 * 60 * 3)
		)
		testService.antigenTest.value = antigenTest
		let sampleCollectionAntigenTestDate = ISO8601DateFormatter.justLocalDateFormatter.string(from: sampleCollectionDate)

		let pcrTest: UserPCRTest = .mock(registrationToken: "regToken")
		let pcrRegistrationDate = ISO8601DateFormatter.justUTCDateFormatter.string(from: pcrTest.registrationDate)
		testService.pcrTest.value = pcrTest
		
		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .extraLong)
		testService.createCoronaTestEntryInContactDiary(coronaTestType: .pcr)
		testService.createCoronaTestEntryInContactDiary(coronaTestType: .antigen)

		let pcrJournalEntry = try XCTUnwrap(diaryStore.coronaTests.first { $0.type == .pcr })
		let antigenJournalEntry = try XCTUnwrap(diaryStore.coronaTests.first { $0.type == .antigen })

		XCTAssertEqual(diaryStore.coronaTests.count, 2)
		XCTAssertEqual(pcrJournalEntry.date, pcrRegistrationDate)
		XCTAssertEqual(antigenJournalEntry.date, sampleCollectionAntigenTestDate)
		XCTAssertTrue(try XCTUnwrap(testService.antigenTest.value?.journalEntryCreated))
		XCTAssertTrue(try XCTUnwrap(testService.pcrTest.value?.journalEntryCreated))
	}

	private func createCoronaTestService(forTestResult testResult: TestResult, sampleCollectionDate: Date? = nil, diaryStore: DiaryStoring = MockDiaryStore()) -> CoronaTestService {
		let sampleTimeInterval: Int?
		if let sampleCollectionDate = sampleCollectionDate {
			sampleTimeInterval = Int(sampleCollectionDate.timeIntervalSince1970)
		} else {
			sampleTimeInterval = nil
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: testResult, on: .pcr), sc: sampleTimeInterval, labId: "SomeLabId")),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: testResult, on: .antigen), sc: sampleTimeInterval, labId: "SomeLabId"))
		])
		

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		return CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
	}
	
	func test_When_UpdateTestResultSuccessWithPending_Then_ContactJournalHasNoEntry() throws {
		let diaryStore = MockDiaryStore()
		let testService = createCoronaTestService(forTestResult: .pending, diaryStore: diaryStore)

		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest.value?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest.value?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithExpired_Then_ContactJournalHasNoEntry() throws {
		let diaryStore = MockDiaryStore()
		let testService = createCoronaTestService(forTestResult: .expired, diaryStore: diaryStore)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest.value?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest.value?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithInvalid_Then_ContactJournalHasNoEntry() throws {

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .invalid, on: .pcr), sc: nil, labId: nil)),
			.success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .invalid, on: .antigen), sc: nil, labId: nil))
		])
		
		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .extraLong)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest.value?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest.value?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithNegative_Then_ContactJournalHasAnEntry() throws {
		let diaryStore = MockDiaryStore()
		let testService = createCoronaTestService(forTestResult: .negative, diaryStore: diaryStore)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .extraLong)
		
		testService.createCoronaTestEntryInContactDiary(coronaTestType: .pcr)
		testService.createCoronaTestEntryInContactDiary(coronaTestType: .antigen)

		XCTAssertEqual(diaryStore.coronaTests.count, 2)
		XCTAssertTrue(try XCTUnwrap(testService.antigenTest.value?.journalEntryCreated))
		XCTAssertTrue(try XCTUnwrap(testService.pcrTest.value?.journalEntryCreated))
	}

	func test_When_UpdateTestResultsSuccessWithExpired_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let testService = createCoronaTestService(forTestResult: .expired)
		testService.antigenTest.value = .mock(registrationToken: "regToken")
		testService.pcrTest.value = .mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateWithForce_And_FinalTestResultExist_Then_ClientIsCalled() {
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		testService.updateTestResults(force: true, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_FinalTestResultExist_Then_ClientIsNotCalled() {
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)

		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_NoFinalTestResultExist_Then_ClientIsCalled() {
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultOlderThan21Days_Then_ClientIsNotCalled() throws {
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredAntigenTestResultWithoutRegistrationDateButPointOfCareConsentDateOlderThan21Days_Then_ClientIsNotCalled() throws {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		
		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true
		
		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(TestResultReceiveModel(testResult: TestResult.serverResponse(for: .expired, on: .antigen), sc: nil, labId: "SomeLabId")),
				willLoadResource: { res in
					if let resource = res as? TestResultResource, !resource.locator.isFake {
						getTestResultExpectation.fulfill()
					}
				})
		])

		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -21, to: Date()))
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .expired
		)

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultYoungerThan21Days_Then_ClientIsCalled() throws {
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredAntigenTestResultWithoutRegistrationDateAndPointOfCareConsentDateYoungerThan21Days_Then_ClientIsCalled() throws {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let dateComponents = DateComponents(day: -21, second: 10)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))
		
		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		
		let restServiceProvider = RestServiceProviderStub(loadResources: [
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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: pointOfCareConsentDate,
			testResult: .expired
		)
		
		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .pcr, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.pcrTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.pcrTest.value = .mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .pcr, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.testResultError(.receivedResourceError(.qrDoesNotExist))))
			XCTAssertEqual(testService.pcrTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.antigenTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {

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
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.testResultError(.receivedResourceError(.qrDoesNotExist))))
			XCTAssertEqual(testService.antigenTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_PointOfCareConsentDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {

		
		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.antigenTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_PointOfCareConsentDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TestResultError>.receivedResourceError(.qrDoesNotExist)),
			.success(RegistrationTokenReceiveModel(submissionTAN: "fake"))
		])

		let dateComponents = DateComponents(day: -21, second: 10)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let testService = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest.value = .mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.testResultError(.receivedResourceError(.qrDoesNotExist))))
			XCTAssertEqual(testService.antigenTest.value?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	// MARK: - Test Removal

	func testMovingCoronaTestToBin() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let recycleBin = RecycleBin(store: store)

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: recycleBin,
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest.value = .mock(registrationToken: "antigenRegistrationToken")

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)
		XCTAssertTrue(store.recycleBinItems.isEmpty)
		XCTAssertTrue(store.recycleBinItemsSubject.value.isEmpty)

		service.moveTestToBin(.pcr)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)
		XCTAssertEqual(store.recycleBinItems.count, 1)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 1)

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken2")

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)

		service.moveTestToBin(.antigen)

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNil(service.antigenTest.value)
		XCTAssertEqual(store.recycleBinItems.count, 2)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 2)

		service.moveTestToBin(.pcr)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNil(service.antigenTest.value)
		XCTAssertEqual(store.recycleBinItems.count, 3)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 3)
	}

	func testDeletingCoronaTest() {
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest.value = .mock(registrationToken: "antigenRegistrationToken")

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)

		service.removeTest(.pcr)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken")

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNotNil(service.antigenTest.value)

		service.removeTest(.antigen)

		XCTAssertNotNil(service.pcrTest.value)
		XCTAssertNil(service.antigenTest.value)

		service.removeTest(.pcr)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertNil(service.antigenTest.value)
	}

	// MARK: - Re-Register

	func testReregisteringShownPositivePCRTestSchedulesWarnOthersReminder() throws {
		let mockNotificationCenter = MockUserNotificationCenter()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let pcrTest: UserPCRTest = .mock(
			registrationToken: "registrationToken",
			testResult: .positive,
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: false,
			keysSubmitted: false
		)

		XCTAssertNil(service.pcrTest.value)
		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		service.reregister(coronaTest: .pcr(pcrTest))

		XCTAssertEqual(service.pcrTest.value, pcrTest)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier
		)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier
		)
	}

	func testReregisteringFormerShownPositivePCRTestDoesNotScheduleWarnOthersReminder() throws {
		let testResults: [TestResult] = [.pending, .negative, .invalid, .expired]

		for testResult in testResults {
			let mockNotificationCenter = MockUserNotificationCenter()

			let store = MockTestStore()
			let appConfiguration = CachedAppConfigurationMock()

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake(),
				revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
			)

			let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
			let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
			
			let service = CoronaTestService(
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					restServiceProvider: RestServiceProviderStub(),
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				ppacService: ppacService,
				notificationCenter: mockNotificationCenter,
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			let pcrTest: UserPCRTest = .mock(
				registrationToken: "registrationToken",
				testResult: testResult,
				positiveTestResultWasShown: true,
				isSubmissionConsentGiven: false,
				keysSubmitted: false
			)

			XCTAssertNil(service.pcrTest.value)
			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

			service.reregister(coronaTest: .pcr(pcrTest))

			XCTAssertEqual(service.pcrTest.value, pcrTest)
			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)
		}
	}

	func testReregisteringPositiveAntigenTestSchedulesWarnOthersReminder() throws {
		let mockNotificationCenter = MockUserNotificationCenter()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let antigenTest: UserAntigenTest = .mock(
			registrationToken: "registrationToken",
			testResult: .positive,
			positiveTestResultWasShown: true,
			isSubmissionConsentGiven: false,
			keysSubmitted: false
		)

		XCTAssertNil(service.antigenTest.value)
		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		service.reregister(coronaTest: .antigen(antigenTest))

		XCTAssertEqual(service.antigenTest.value, antigenTest)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier
		)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier
		)
	}

	func testReregisteringShownPositiveAntigenTestDoesNotScheduleWarnOthersReminder() throws {
		let testResults: [TestResult] = [.pending, .negative, .invalid, .expired]

		for testResult in testResults {
			let mockNotificationCenter = MockUserNotificationCenter()

			let store = MockTestStore()
			let appConfiguration = CachedAppConfigurationMock()

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake(),
				revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
			)

			let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
			let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
			
			let service = CoronaTestService(
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					restServiceProvider: RestServiceProviderStub(),
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				ppacService: ppacService,
				notificationCenter: mockNotificationCenter,
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			let antigenTest: UserAntigenTest = .mock(
				registrationToken: "registrationToken",
				testResult: testResult,
				positiveTestResultWasShown: true,
				isSubmissionConsentGiven: false,
				keysSubmitted: false
			)

			XCTAssertNil(service.antigenTest.value)
			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

			service.reregister(coronaTest: .antigen(antigenTest))

			XCTAssertEqual(service.antigenTest.value, antigenTest)
			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)
		}
	}

	// MARK: - Evaluate Showing of Test

	func testEvaluateShowingOfPositivePCRTestUpdatesTestAndSchedulesWarnOthersReminder() throws {
		let mockNotificationCenter = MockUserNotificationCenter()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)
		
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)

		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		service.pcrTest.value = .mock(
			registrationToken: "registrationToken",
			testResult: .positive,
			positiveTestResultWasShown: false,
			isSubmissionConsentGiven: false,
			keysSubmitted: false
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		service.evaluateShowingTest(ofType: .pcr)

		XCTAssertTrue(try XCTUnwrap(service.pcrTest.value?.positiveTestResultWasShown))

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder1.identifier
		)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.pcrWarnOthersReminder2.identifier
		)
	}

	func testEvaluateShowingOfFormerShownPositivePCRTestDoesNotScheduleWarnOthersReminder() throws {
		let testResults: [TestResult] = [.pending, .negative, .invalid, .expired]

		for testResult in testResults {
			let mockNotificationCenter = MockUserNotificationCenter()

			let store = MockTestStore()
			let appConfiguration = CachedAppConfigurationMock()

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake(),
				revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
			)

			let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
			let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
			
			let service = CoronaTestService(
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					restServiceProvider: RestServiceProviderStub(),
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				ppacService: ppacService,
				notificationCenter: mockNotificationCenter,
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			service.pcrTest.value = .mock(
				registrationToken: "registrationToken",
				testResult: testResult,
				positiveTestResultWasShown: true,
				isSubmissionConsentGiven: false,
				keysSubmitted: false
			)

			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

			service.evaluateShowingTest(ofType: .pcr)

			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)
		}
	}

	func testEvaluateShowingOfPositiveAntigenTestUpdatesTestAndSchedulesWarnOthersReminder() throws {
		let mockNotificationCenter = MockUserNotificationCenter()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		service.antigenTest.value = .mock(
			registrationToken: "registrationToken",
			testResult: .positive,
			positiveTestResultWasShown: false,
			isSubmissionConsentGiven: false,
			keysSubmitted: false
		)

		XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

		service.evaluateShowingTest(ofType: .antigen)

		XCTAssertTrue(try XCTUnwrap(service.antigenTest.value?.positiveTestResultWasShown))

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[0].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder1.identifier
		)
		XCTAssertEqual(
			mockNotificationCenter.notificationRequests[1].identifier,
			ActionableNotificationIdentifier.antigenWarnOthersReminder2.identifier
		)
	}

	func testEvaluateShowingOfFormerShownPositiveAntigenTestDoesNotScheduleWarnOthersReminder() throws {
		let testResults: [TestResult] = [.pending, .negative, .invalid, .expired]

		for testResult in testResults {
			let mockNotificationCenter = MockUserNotificationCenter()

			let store = MockTestStore()
			let appConfiguration = CachedAppConfigurationMock()

			let healthCertificateService = HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: .fake(),
				revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
			)

			let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
			let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
			
			let service = CoronaTestService(
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService,
				healthCertificateRequestService: HealthCertificateRequestService(
					store: store,
					restServiceProvider: RestServiceProviderStub(),
					appConfiguration: appConfiguration,
					healthCertificateService: healthCertificateService
				),
				ppacService: ppacService,
				notificationCenter: mockNotificationCenter,
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			service.antigenTest.value = .mock(
				registrationToken: "registrationToken",
				testResult: testResult,
				positiveTestResultWasShown: false,
				isSubmissionConsentGiven: false,
				keysSubmitted: false
			)

			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)

			service.evaluateShowingTest(ofType: .antigen)

			XCTAssertTrue(mockNotificationCenter.notificationRequests.isEmpty)
		}
	}

	// MARK: - Plausible Deniability

	func test_registerPCRTestAndGetResultPlaybook() {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
				LoadResource(
					result: .success(
						TeleTanReceiveModel(registrationToken: "dummyRegToken")
					),
					willLoadResource: { resource in
						guard let resource = resource as? TeleTanResource  else {
							XCTFail("TeleTanResource expected.")
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
					willLoadResource: { _ in
						expectation.fulfill()
						XCTAssertEqual(count, 1)
						count += 1
					}),
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						expectation.fulfill()
						XCTAssertTrue(submissionResource.locator.isFake)
						XCTAssertEqual(count, 2)
						count += 1
					}
				)
			],
			isFakeResourceLoadingActive: true
		)

		// Run test.

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = .mock(registrationToken: "regToken")
		service.antigenTest.value = .mock(registrationToken: "regToken")

		service.registerPCRTest(
			teleTAN: "test-teletan",
			isSubmissionConsentGiven: true
		) { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success:
				break
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_getTestResultPlaybookPositive() {
		getTestResultPlaybookTest(for: .pcr, with: .positive)
		getTestResultPlaybookTest(for: .antigen, with: .positive)
	}

	func test_getTestResultPlaybookNegative() {
		getTestResultPlaybookTest(for: .pcr, with: .negative)
		getTestResultPlaybookTest(for: .antigen, with: .negative)
	}

	func test_getTestResultPlaybookPending() {
		getTestResultPlaybookTest(for: .pcr, with: .pending)
		getTestResultPlaybookTest(for: .antigen, with: .pending)
	}

	func test_getTestResultPlaybookInvalid() {
		getTestResultPlaybookTest(for: .pcr, with: .invalid)
		getTestResultPlaybookTest(for: .antigen, with: .invalid)
	}

	func test_getTestResultPlaybookExpired() {
		getTestResultPlaybookTest(for: .pcr, with: .expired)
		getTestResultPlaybookTest(for: .antigen, with: .expired)
	}

	// MARK: - Private

	private func getTestResultPlaybookTest(for coronaTestType: CoronaTestType, with testResult: TestResult) {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let restServiceProvider = RestServiceProviderStub(
			loadResources: [
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
					}),
				// Key submission result.
				LoadResource(
					result: .success(()),
					willLoadResource: { resource in
						guard let submissionResource = resource as? KeySubmissionResource else {
							XCTFail("KeySubmissionResource expected.")
							return
						}
						expectation.fulfill()
						XCTAssertTrue(submissionResource.locator.isFake)
						XCTAssertEqual(count, 2)
						count += 1
					}
				)
			],
			isFakeResourceLoadingActive: true
		)
		
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: .fake(),
			revocationProvider: RevocationProvider(restService: RestServiceProviderStub(), store: MockTestStore())
		)

		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "SomeToken")
		let ppacService = PPACService(store: store, deviceCheck: deviceCheck)
		
		let service = CoronaTestService(
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				restServiceProvider: RestServiceProviderStub(),
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			ppacService: ppacService,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest.value = .mock(registrationToken: "regToken")
		service.antigenTest.value = .mock(registrationToken: "regToken")

		// Run test.

		service.updateTestResult(for: coronaTestType) { response in
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
