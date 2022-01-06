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
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
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

	func testHasAtLeastOneShownPositiveOrSubmittedTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		XCTAssertFalse(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.pcrTest = PCRTest.mock(positiveTestResultWasShown: false, keysSubmitted: false)
		XCTAssertFalse(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.antigenTest = AntigenTest.mock(positiveTestResultWasShown: false, keysSubmitted: false)
		XCTAssertFalse(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.pcrTest?.positiveTestResultWasShown = true
		XCTAssertTrue(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.pcrTest?.positiveTestResultWasShown = false
		service.antigenTest?.positiveTestResultWasShown = true
		XCTAssertTrue(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.antigenTest?.positiveTestResultWasShown = false
		service.pcrTest?.keysSubmitted = true
		XCTAssertTrue(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.pcrTest?.keysSubmitted = false
		service.antigenTest?.keysSubmitted = true
		XCTAssertTrue(service.hasAtLeastOneShownPositiveOrSubmittedTest)

		service.antigenTest?.keysSubmitted = false
		XCTAssertFalse(service.hasAtLeastOneShownPositiveOrSubmittedTest)
	}

	func testOutdatedPublisherSetForAlreadyOutdatedNegativeAntigenTestWithoutSampleCollectionDate() {
		var defaultAppConfig = CachedAppConfigurationMock.defaultAppConfiguration
		defaultAppConfig.coronaTestParameters.coronaRapidAntigenTestParameters.hoursToDeemTestOutdated = 48
		let appConfiguration = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		service.antigenTest = AntigenTest.mock(
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

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		// Outdated only according to sample collection date, not according to point of care consent date
		// As we are using the sample collection date if set, the test is outdated
		service.antigenTest = AntigenTest.mock(
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

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 3

		let expectedValues = [false, false, true]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink {
				receivedValues.append($0)
				publisherExpectation.fulfill()
			}

		service.antigenTest = AntigenTest.mock(
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

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 4

		let expectedValues = [false, false, true, false]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Remove test as soon as outdated state is set
				if antigenTestIsOutdated {
					service.removeTest(.antigen)
				}
			}

		service.antigenTest = AntigenTest.mock(
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

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 4

		let expectedValues = [false, false, true, false]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Replace test as soon as outdated state is set
				if antigenTestIsOutdated && service.antigenTest?.registrationToken == "1" {
					service.antigenTest = AntigenTest.mock(
						registrationToken: "2",
						pointOfCareConsentDate: Date(),
						testResult: .pending
					)
				}
			}

		service.antigenTest = AntigenTest.mock(
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
		let appConfig = CachedAppConfigurationMock(with: defaultAppConfig)

		let client = ClientMock()
		let store = MockTestStore()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfig,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfig,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		let publisherExpectation = expectation(description: "")
		publisherExpectation.expectedFulfillmentCount = 5

		let expectedValues = [false, false, true, false, true]

		var receivedValues = [Bool]()
		let subscription = service.$antigenTestIsOutdated
			.sink { antigenTestIsOutdated in
				receivedValues.append(antigenTestIsOutdated)
				publisherExpectation.fulfill()

				// Replace test as soon as outdated state is set
				if antigenTestIsOutdated && service.antigenTest?.registrationToken == "1" {
					service.antigenTest = AntigenTest.mock(
						registrationToken: "2",
						pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
						testResult: .negative
					)
				}
			}

		service.antigenTest = AntigenTest.mock(
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
			let appConfig = CachedAppConfigurationMock(with: defaultAppConfig)

			let client = ClientMock()
			let store = MockTestStore()

			let service = CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfig,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfig,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(store: store, client: client)
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			)

			let publisherExpectation = expectation(description: "")
			publisherExpectation.expectedFulfillmentCount = 2

			let expectedValues = [false, false]

			var receivedValues = [Bool]()
			let subscription = service.$antigenTestIsOutdated
				.sink {
					receivedValues.append($0)
					publisherExpectation.fulfill()
				}

			service.antigenTest = AntigenTest.mock(
				pointOfCareConsentDate: Date(timeIntervalSinceNow: -(60 * 60 * 48)),
				testResult: testResult
			)

			waitForExpectations(timeout: .short)

			XCTAssertEqual(receivedValues, expectedValues)

			subscription.cancel()
		}
	}

	func testCoronaTestOfType() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		XCTAssertNil(service.coronaTest(ofType: .pcr))
		XCTAssertNil(service.coronaTest(ofType: .antigen))

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "antigenRegistrationToken")

		XCTAssertEqual(service.coronaTest(ofType: .pcr)?.registrationToken, "pcrRegistrationToken")
		XCTAssertEqual(service.coronaTest(ofType: .antigen)?.registrationToken, "antigenRegistrationToken")
	}

	// MARK: - Test Registration

	func testRegisterPCRTestAndGetResult_successWithoutSubmissionOrCertificateConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(TestResultModel(testResult: TestResult.pending.rawValue, sc: nil, labId: "SomeLabId"))

		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			isSubmissionConsentGiven: false,
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

		guard let pcrTest = service.pcrTest else {
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()
		
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "registrationToken2")
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
				result: .success(TestResultModel(testResult: TestResult.negative.rawValue, sc: nil, labId: nil)), willLoadResource: nil)
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
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

		service.pcrTest = nil

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

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		countSubscription.cancel()

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
		XCTAssertTrue(pcrTest.journalEntryCreated)
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "registrationToken2")
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
				result: .success(TestResultModel(testResult: TestResult.negative.rawValue, sc: nil, labId: nil)), willLoadResource: nil)
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: badgeWrapper
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

		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915",
			qrCodeHash: "",
			isSubmissionConsentGiven: true,
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

		guard let pcrTest = service.pcrTest else {
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "registrationToken2")
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
				result: .success(TestResultModel(testResult: TestResult.negative.rawValue, sc: nil, labId: nil)), willLoadResource: nil)
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "F1EE0D-F1EE0D4D-4346-4B63-B9CF-1522D9200915",
			qrCodeHash: "",
			isSubmissionConsentGiven: true,
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

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertFalse(pcrTest.certificateConsentGiven)
		XCTAssertFalse(pcrTest.certificateRequested)
	}

	func testRegisterPCRTestAndGetResult_RegistrationFails() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			// the extra load response if for the fakeVerificationServerRequest for PlausibleDeniability
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "",
			isSubmissionConsentGiven: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .serviceError(.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.pcrTest)
		XCTAssertNil(store.pcrTestResultMetadata)
	}

	func testRegisterPCRTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.serverError(500)))
		}

		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTestAndGetResult(
			guid: "guid",
			qrCodeHash: "qrCodeHash",
			isSubmissionConsentGiven: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .responseFailure(.serverError(500)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let pcrTest = service.pcrTest else {
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		let checkInMock = Checkin.mock()
		let eventStore = MockEventStore()
		eventStore.createCheckin(checkInMock)

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: eventStore,
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		Analytics.setupMock(
			store: store,
			coronaTestService: service
		)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		
		service.pcrTest = nil

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

		guard let pcrTest = service.pcrTest else {
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
		XCTAssertEqual(store.pcrKeySubmissionMetadata?.submittedWithCheckIns, true)
	}

	func testRegisterPCRTestWithTeleTAN_successWithSubmissionConsentGiven() {
		let store = MockTestStore()
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(
				RegistrationTokenModel(registrationToken: "registrationToken2")
			),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		
		service.pcrTest = nil

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

		guard let pcrTest = service.pcrTest else {
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.teleTanAlreadyUsed)),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let diaryStore = MockDiaryStore()
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerPCRTest(
			teleTAN: "tele-tan",
			isSubmissionConsentGiven: true
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .serviceError(.receivedResourceError(.teleTanAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.pcrTest)
		XCTAssertNil(store.pcrTestResultMetadata)
		XCTAssertTrue(diaryStore.coronaTests.isEmpty)
	}

	func testRegisterAntigenTestAndGetResult_successWithoutSubmissionConsentGivenWithTestedPerson() {
		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "registrationToken")
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
				result: .success(TestResultModel(testResult: TestResult.pending.rawValue, sc: 123456789, labId: "SomeLabId")), willLoadResource: nil)
		])

		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
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

		guard let antigenTest = service.antigenTest else {
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
				RegistrationTokenModel(registrationToken: "registrationToken")
			),
			.success(TestResultModel(testResult: TestResult.pending.rawValue, sc: nil, labId: nil)),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
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
		
		service.pcrTest = nil

		service.antigenTest = nil

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

		guard let antigenTest = service.antigenTest else {
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
		store.enfRiskCalculationResult = mockRiskCalculationResult()

		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "registrationToken")
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
				   result: .success(TestResultModel(testResult: TestResult.negative.rawValue, sc: nil, labId: nil)), willLoadResource: nil
			)
		])

		let client = ClientMock()

		let appConfiguration = CachedAppConfigurationMock()
		let badgeWrapper = HomeBadgeWrapper.fake()
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
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

		service.antigenTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: "Erika",
			lastName: "Mustermann",
			dateOfBirth: "1964-08-12",
			isSubmissionConsentGiven: false,
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

		guard let antigenTest = service.antigenTest else {
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
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.failure(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .serviceError(ServiceError<TeleTanError>.receivedResourceError(.qrAlreadyUsed)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		XCTAssertNil(service.antigenTest)
	}

	func testRegisterAntigenTestAndGetResult_RegistrationSucceedsGettingTestResultFails() {
		let client = ClientMock()

		let restServiceProvider = RestServiceProviderStub(results: [
			.success(RegistrationTokenModel(registrationToken: "registrationToken")),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		]
		)

		client.onGetTestResult = { _, _, completion in
			completion(.failure(.serverError(500)))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = nil

		let expectation = self.expectation(description: "Expect to receive a result.")

		service.registerAntigenTestAndGetResult(
			with: "hash",
			qrCodeHash: "qrCodeHash",
			pointOfCareConsentDate: Date(timeIntervalSince1970: 2222),
			firstName: nil,
			lastName: nil,
			dateOfBirth: nil,
			isSubmissionConsentGiven: true,
			certificateSupportedByPointOfCare: false,
			certificateConsent: .notGiven
		) { result in
			expectation.fulfill()
			switch result {
			case .failure(let error):
				XCTAssertEqual(error, .responseFailure(.serverError(500)))
			case .success:
				XCTFail("This test should always return a failure.")
			}
		}

		waitForExpectations(timeout: .short)

		guard let antigenTest = service.antigenTest else {
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

	// MARK: - Test Result Update

	func testUpdatePCRTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(TestResultModel(testResult: TestResult.positive.rawValue, sc: nil, labId: nil))
		])

		let client = ClientMock()

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = PCRTest.mock(registrationToken: "regToken")

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

		guard let pcrTest = service.pcrTest else {
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

	func testUpdateAntigenTestResult_success() {
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(TestResultModel(testResult: TestResult.positive.rawValue, sc: nil, labId: nil)),
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		
		let client = ClientMock()
		
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		
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
		
		guard let antigenTest = service.antigenTest else {
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
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = nil

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
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = nil

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
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = PCRTest.mock(registrationToken: nil)

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

		guard let pcrTest = service.pcrTest else {
			XCTFail("pcrTest should not be nil")
			return
		}

		XCTAssertEqual(pcrTest.testResult, .pending)
		XCTAssertNil(pcrTest.finalTestResultReceivedDate)
	}

	func testUpdateAntigenTestResult_noRegistrationToken() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.antigenTest = AntigenTest.mock(registrationToken: nil)

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

		guard let antigenTest = service.antigenTest else {
			XCTFail("antigenTest should not be nil")
			return
		}

		XCTAssertEqual(antigenTest.testResult, .pending)
		XCTAssertNil(antigenTest.finalTestResultReceivedDate)
	}

	func test_When_UpdatePresentNotificationTrue_Then_NotificationShouldBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.positive.rawValue)))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(SubmissionTANModel(submissionTAN: "fake")),
			.success(SubmissionTANModel(submissionTAN: "fake"))

		])

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

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
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 2)
	}

	func test_When_UpdatePresentNotificationFalse_Then_NotificationShouldNOTBePresented() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.positive.rawValue)))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: false) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultsFails_Then_ErrorIsReturned() {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.invalidResponse))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { result in
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
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.pending.rawValue)))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateTestResultSuccessWithPositive_Then_ContactJournalHasAnEntry() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let sampleCollectionDate = Date()

		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.positive.rawValue, sc: Int(sampleCollectionDate.timeIntervalSince1970))))
		}

		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		let antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: Date(timeIntervalSinceNow: -24 * 60 * 60 * 3)
		)
		testService.antigenTest = antigenTest
		let sampleCollectionAntigenTestDate = ISO8601DateFormatter.justLocalDateFormatter.string(from: sampleCollectionDate)

		let pcrTest = PCRTest.mock(registrationToken: "regToken")
		let pcrRegistrationDate = ISO8601DateFormatter.justUTCDateFormatter.string(from: pcrTest.registrationDate)
		testService.pcrTest = pcrTest

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		let pcrJournalEntry = try XCTUnwrap(diaryStore.coronaTests.first { $0.type == .pcr })
		let antigenJournalEntry = try XCTUnwrap(diaryStore.coronaTests.first { $0.type == .antigen })

		XCTAssertEqual(diaryStore.coronaTests.count, 2)
		XCTAssertEqual(pcrJournalEntry.date, pcrRegistrationDate)
		XCTAssertEqual(antigenJournalEntry.date, sampleCollectionAntigenTestDate)
		XCTAssertTrue(try XCTUnwrap(testService.antigenTest?.journalEntryCreated))
		XCTAssertTrue(try XCTUnwrap(testService.pcrTest?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithPending_Then_ContactJournalHasNoEntry() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.pending.rawValue)))
		}

		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithExpired_Then_ContactJournalHasNoEntry() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithInvalid_Then_ContactJournalHasNoEntry() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.invalid.rawValue)))
		}

		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 0)
		XCTAssertFalse(try XCTUnwrap(testService.antigenTest?.journalEntryCreated))
		XCTAssertFalse(try XCTUnwrap(testService.pcrTest?.journalEntryCreated))
	}

	func test_When_UpdateTestResultSuccessWithNegative_Then_ContactJournalHasAnEntry() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.negative.rawValue)))
		}

		let diaryStore = MockDiaryStore()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: diaryStore,
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(diaryStore.coronaTests.count, 2)
		XCTAssertTrue(try XCTUnwrap(testService.antigenTest?.journalEntryCreated))
		XCTAssertTrue(try XCTUnwrap(testService.pcrTest?.journalEntryCreated))
	}

	func test_When_UpdateTestResultsSuccessWithExpired_Then_NoNotificationIsShown() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(registrationToken: "regToken")
		testService.pcrTest = PCRTest.mock(registrationToken: "regToken")

		let completionExpectation = expectation(description: "Completion should be called.")
		testService.updateTestResults(presentNotification: true) { _ in
			completionExpectation.fulfill()
		}
		waitForExpectations(timeout: .short)

		XCTAssertEqual(mockNotificationCenter.notificationRequests.count, 0)
	}

	func test_When_UpdateWithForce_And_FinalTestResultExist_Then_ClientIsCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()


		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		testService.updateTestResults(force: true, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_FinalTestResultExist_Then_ClientIsNotCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()


		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: Date()
		)

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		client.onGetTestResult = { _, _, _ in
			getTestResultExpectation.fulfill()
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdateWithoutForce_And_NoFinalTestResultExist_Then_ClientIsCalled() {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()


		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			finalTestResultReceivedDate: nil
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultOlderThan21Days_Then_ClientIsNotCalled() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -21, to: Date()))


		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		client.onGetTestResult = { _, _, _ in
			getTestResultExpectation.fulfill()
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredAntigenTestResultWithoutRegistrationDateButPointOfCareConsentDateOlderThan21Days_Then_ClientIsNotCalled() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -21, to: Date()))
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .expired
		)

		let getTestResultExpectation = expectation(description: "Get Test result should NOT be called.")
		getTestResultExpectation.isInverted = true

		client.onGetTestResult = { _, _, _ in
			getTestResultExpectation.fulfill()
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredTestResultYoungerThan21Days_Then_ClientIsCalled() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let dateComponents = DateComponents(day: -21, second: 10)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))
		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .expired
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")
		getTestResultExpectation.expectedFulfillmentCount = 2

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingExpiredAntigenTestResultWithoutRegistrationDateAndPointOfCareConsentDateYoungerThan21Days_Then_ClientIsCalled() throws {
		let mockNotificationCenter = MockUserNotificationCenter()
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let dateComponents = DateComponents(day: -21, second: 10)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let testService = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: mockNotificationCenter,
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			registrationDate: pointOfCareConsentDate,
			testResult: .expired
		)

		let getTestResultExpectation = expectation(description: "Get Test result should be called.")

		client.onGetTestResult = { _, _, completion in
			getTestResultExpectation.fulfill()
			completion(.success(.fake(testResult: TestResult.expired.rawValue)))
		}

		testService.updateTestResults(force: false, presentNotification: false) { _ in }

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .pcr, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.pcrTest?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingPCRTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.pcrTest = PCRTest.mock(
			registrationToken: "regToken",
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .pcr, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.responseFailure(.qrDoesNotExist)))
			XCTAssertEqual(testService.pcrTest?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))
		// Set point of care date to younger than 21 days to ensure that registration date wins
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.antigenTest?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_RegistrationDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		let registrationDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21, second: 10), to: Date()))
		// Set point of care date to older than 21 days to ensure that registration date wins
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -21), to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: registrationDate,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.responseFailure(.qrDoesNotExist)))
			XCTAssertEqual(testService.antigenTest?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_PointOfCareConsentDateOlderThan21Days_Then_ExpiredTestResultIsSetAndReturnedWithoutError() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])
		let dateComponents = DateComponents(day: -21)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .success(.expired))
			XCTAssertEqual(testService.antigenTest?.testResult, .expired)
			completionExpectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

	func test_When_UpdatingAntigenTestResultWithErrorCode400_And_PointOfCareConsentDateYoungerThan21Days_Then_ExpiredTestResultIsSetAndErrorReturned() throws {
		let client = ClientMock()
		client.onGetTestResult = { _, _, completion in
			completion(.failure(.qrDoesNotExist))
		}
		let restServiceProvider = RestServiceProviderStub(results: [
			.success(SubmissionTANModel(submissionTAN: "fake"))
		])

		let dateComponents = DateComponents(day: -21, second: 10)
		let pointOfCareConsentDate = try XCTUnwrap(Calendar.current.date(byAdding: dateComponents, to: Date()))

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let testService = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			notificationCenter: MockUserNotificationCenter(),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		testService.antigenTest = AntigenTest.mock(
			registrationToken: "regToken",
			pointOfCareConsentDate: pointOfCareConsentDate,
			registrationDate: nil,
			testResult: .negative
		)

		let completionExpectation = expectation(description: "Completion should be called.")

		testService.updateTestResult(for: .antigen, force: true, presentNotification: false) {
			XCTAssertEqual($0, .failure(.responseFailure(.qrDoesNotExist)))
			XCTAssertEqual(testService.antigenTest?.testResult, .expired)
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

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: recycleBin
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "antigenRegistrationToken")

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)
		XCTAssertTrue(store.recycleBinItems.isEmpty)
		XCTAssertTrue(store.recycleBinItemsSubject.value.isEmpty)

		service.moveTestToBin(.pcr)

		XCTAssertNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)
		XCTAssertEqual(store.recycleBinItems.count, 1)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 1)

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken2")

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)

		service.moveTestToBin(.antigen)

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNil(service.antigenTest)
		XCTAssertEqual(store.recycleBinItems.count, 2)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 2)

		service.moveTestToBin(.pcr)

		XCTAssertNil(service.pcrTest)
		XCTAssertNil(service.antigenTest)
		XCTAssertEqual(store.recycleBinItems.count, 3)
		XCTAssertEqual(store.recycleBinItemsSubject.value.count, 3)
	}

	func testDeletingCoronaTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "antigenRegistrationToken")

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)

		service.removeTest(.pcr)

		XCTAssertNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken")

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNotNil(service.antigenTest)

		service.removeTest(.antigen)

		XCTAssertNotNil(service.pcrTest)
		XCTAssertNil(service.antigenTest)

		service.removeTest(.pcr)

		XCTAssertNil(service.pcrTest)
		XCTAssertNil(service.antigenTest)
	}

	// MARK: - Plausible Deniability

	func test_registerPCRTestAndGetResultPlaybook() {
		// Counter to track the execution order.
		var count = 0

		let expectation = self.expectation(description: "execute all callbacks")
		expectation.expectedFulfillmentCount = 4

		// Initialize.

		let restServiceProvider = RestServiceProviderStub(loadResources: [
			LoadResource(
				result: .success(
					RegistrationTokenModel(registrationToken: "dummyRegToken")
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
					SubmissionTANModel(submissionTAN: "fake")
				),
				willLoadResource: { _ in
					expectation.fulfill()
					XCTAssertEqual(count, 1)
					count += 1
				})
		])

		let client = ClientMock()

		client.onSubmitCountries = { _, isFake, completion in
			expectation.fulfill()
			XCTAssertTrue(isFake)
			XCTAssertEqual(count, 2)
			count += 1
			completion(.success(()))
		}

		// Run test.

		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = PCRTest.mock(registrationToken: "regToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "regToken")

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
				result: .success(TestResultModel(testResult: testResult.rawValue, sc: nil, labId: nil)),
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
					SubmissionTANModel(submissionTAN: "fake")
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
		let service = CoronaTestService(
			client: client,
			restServiceProvider: restServiceProvider,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				boosterNotificationsService: BoosterNotificationsService(
					rulesDownloadService: RulesDownloadService(store: store, client: client)
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		service.pcrTest = PCRTest.mock(registrationToken: "regToken")
		service.antigenTest = AntigenTest.mock(registrationToken: "regToken")

		// Run test.

		service.updateTestResult(for: coronaTestType) { response in
			switch response {
			case .failure(let error):
				XCTFail(error.localizedDescription)
			case .success(let result):
				XCTAssertEqual(result.rawValue, testResult.rawValue)
			}

			expectation.fulfill()
		}

		waitForExpectations(timeout: .short)
	}

 	private func mockRiskCalculationResult() -> ENFRiskCalculationResult {
 		ENFRiskCalculationResult(
 			riskLevel: .high,
 			minimumDistinctEncountersWithLowRisk: 0,
 			minimumDistinctEncountersWithHighRisk: 0,
 			mostRecentDateWithLowRisk: Date(),
 			mostRecentDateWithHighRisk: Date(),
 			numberOfDaysWithLowRisk: 0,
 			numberOfDaysWithHighRisk: 2,
 			calculationDate: Date(),
 			riskLevelPerDate: [:],
 			minimumDistinctEncountersWithHighRiskPerDate: [:]
 		)
 	}

	// swiftlint:disable:next file_length
}
