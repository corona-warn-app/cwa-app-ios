////
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class PPAnalyticsSubmitterTests: CWATestCase {
	
	// MARK: - Success
	
	func testGIVEN_SubmissionIsTriggered_WHEN_EverythingIsGiven_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.lastAppReset = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		let ppacToken = PPACToken(apiToken: "FakeApiToken", deviceToken: "FakeDeviceToken")
		
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		let currentENFRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		
		let currentCheckinRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		store.currentENFRiskExposureMetadata = currentENFRiskExposureMetadata
		store.currentCheckinRiskExposureMetadata = currentCheckinRiskExposureMetadata
		
		XCTAssertNil(store.previousENFRiskExposureMetadata)
		XCTAssertNil(store.previousCheckinRiskExposureMetadata)
		
		// WHEN
		analyticsSubmitter.triggerSubmitData(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				expectation.fulfill()
			case let .failure(error):
				XCTFail("Test should not fail. Received error: \(error)")
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		
		/// Check that store is setup correctly after successful submission
		XCTAssertEqual(store.previousENFRiskExposureMetadata, currentENFRiskExposureMetadata)
		XCTAssertEqual(store.previousCheckinRiskExposureMetadata, currentCheckinRiskExposureMetadata)
		XCTAssertNil(store.currentENFRiskExposureMetadata)
		XCTAssertNil(store.currentCheckinRiskExposureMetadata)
		XCTAssertNil(store.pcrTestResultMetadata)
		XCTAssertNil(store.pcrKeySubmissionMetadata)
		XCTAssertNil(store.exposureWindowsMetadata?.newExposureWindowsQueue)
		
		/// Since the Date is super precise we have to be fuzzy here, and since we know our CI lets me a lot fuzzy here.
		let someTimeAgo = Calendar.current.date(byAdding: .second, value: -20, to: Date())
		let someTimeAgoTimeRange = try XCTUnwrap(someTimeAgo)...Date()
		XCTAssertTrue(someTimeAgoTimeRange.contains(try XCTUnwrap(store.lastSubmissionAnalytics)))
	}
	
	// MARK: - KeySubmissionMetaData
	
	func testGIVEN_SubmissionIsTriggered_WHEN_TestPostiveANDSubmitted_THEN_KeySubmissionMetadataIsSubmitted() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		store.antigenTest = .mock(testResult: .positive, keysSubmitted: true)
		store.antigenKeySubmissionMetadata = .mock(submitted: true)
		
		// WHEN
		
		let ppaProtobuf = analyticsSubmitter.getPPADataMessage()
		
		// THEN
		
		XCTAssertFalse(ppaProtobuf.keySubmissionMetadataSet.isEmpty, "keySubmissionMetadataSet must not be empty")
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_TestPostiveANDTimeDifference_THEN_KeySubmissionMetadataIsSubmitted() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		
		store.antigenTest = .mock(testResult: .positive, finalTestResultReceivedDate: Date(), keysSubmitted: true)
		store.antigenKeySubmissionMetadata = .mock()
		
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		// WHEN
		
		let ppaProtobuf = analyticsSubmitter.getPPADataMessage()
		
		// THEN
		
		XCTAssertFalse(ppaProtobuf.keySubmissionMetadataSet.isEmpty, "keySubmissionMetadataSet must not be empty")
	}
	
	
	func testGIVEN_SubmissionIsTriggered_WHEN_TestPostiveANDTimeDifferenceWrongANDNotSubmitted_THEN_KeySubmissionMetadataIsNotSubmitted() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		
		store.antigenTest = .mock(
			testResult: .positive,
			finalTestResultReceivedDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
			keysSubmitted: false
		)
		store.antigenKeySubmissionMetadata = .mock()
		
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		// WHEN
		
		let ppaProtobuf = analyticsSubmitter.getPPADataMessage()
		
		// THEN
		
		XCTAssertTrue(ppaProtobuf.keySubmissionMetadataSet.isEmpty, "keySubmissionMetadataSet must be empty")
	}
	
	
	func testGIVEN_SubmissionIsTriggered_WHEN_TestNegativeANDSubmitted_THEN_KeySubmissionMetadataIsNotSubmitted() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		
		store.antigenTest = .mock(
			testResult: .negative,
			keysSubmitted: true
		)
		store.antigenKeySubmissionMetadata = .mock()
		
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		// WHEN
		
		let ppaProtobuf = analyticsSubmitter.getPPADataMessage()
		
		// THEN
		
		XCTAssertTrue(ppaProtobuf.keySubmissionMetadataSet.isEmpty, "keySubmissionMetadataSet must be empty")
	}
	
	// MARK: - Failures
	
	func testGIVEN_SubmissionIsTriggered_WHEN_UserConsentIsMissing_THEN_UserConsentErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		
		// WHEN
		store.isPrivacyPreservingAnalyticsConsentGiven = false
		
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .userConsentError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_AppConfigIsMissing_THEN_ProbibilityErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .probibilityError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_ProbabilityIsLow_THEN_ProbibilityErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always fail
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = -1
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .probibilityError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_SubmissionWas2HoursAgo_THEN_SubmissionTimeAmountUndercutErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .submissionTimeAmountUndercutError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_SubmissionWas23Hours53MinutesAgo_THEN_SubmissionTimeAmountUndercutErrorIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		// Test edge case when 2 minutes remain to submit again.
		let twentyThreeHoursAgo = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -23, to: Date()))
		let twentyThreeHoursFiftyThreeMinutesAgo = Calendar.current.date(byAdding: .minute, value: -53, to: twentyThreeHoursAgo)
		store.lastSubmissionAnalytics = twentyThreeHoursFiftyThreeMinutesAgo
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .submissionTimeAmountUndercutError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_OnboardingWas2HoursAgo_THEN_OnboardingErrorIsReturned() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		// Test edge case when we can submit since 2 minutes.
		let twentyThreeHoursAgo = try XCTUnwrap(Calendar.current.date(byAdding: .hour, value: -23, to: Date()))
		let twentyThreeHoursFiftySevenMinutesAgo = Calendar.current.date(byAdding: .minute, value: -57, to: twentyThreeHoursAgo)
		
		store.lastSubmissionAnalytics = twentyThreeHoursFiftySevenMinutesAgo
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .onboardingError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_AppResetWas2HoursAgo_THEN_AppResetErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.lastAppReset = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .appResetError)
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_PpacCouldNotAuthorize_THEN_PpacErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(false, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.lastAppReset = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		
		// WHEN
		var ppasError: PPASError?
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not succeed")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .ppacError(.generationFailed))
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_SeveralTimes_THEN_SubmissionInProgressErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called with an error")
		expectation.expectedFulfillmentCount = 2
		
		// WHEN
		var ppasErrors: [PPASError] = []
		var ppasSuccess: [Void] = []
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case let .success(success):
				ppasSuccess.append(success)
			case let .failure(error):
				ppasErrors.append(error)
			}
			expectation.fulfill()
		})
		
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case let .success(success):
				ppasSuccess.append(success)
			case let .failure(error):
				ppasErrors.append(error)
			}
			expectation.fulfill()
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasSuccess.count, 1)
		XCTAssertEqual(ppasErrors.count, 1)
		XCTAssertTrue(ppasErrors.contains(.submissionInProgress))
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_EverythingIsGiven_THEN_FailureAtServer() throws {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		client.onSubmitAnalytics = { _, _, _, completion in
			completion(.failure(.generalError))
		}
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
		
		let expectation = self.expectation(description: "completion handler is called without an error")
		
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.lastAppReset = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		let ppacToken = PPACToken(apiToken: "FakeApiToken", deviceToken: "FakeDeviceToken")
		
		let twoDaysBefore = Calendar.current.date(byAdding: .day, value: -2, to: Date())
		let currentENFRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: true
		)
		
		let currentCheckinRiskExposureMetadata = RiskExposureMetadata(
			riskLevel: .low,
			riskLevelChangedComparedToPreviousSubmission: false,
			mostRecentDateAtRiskLevel: twoDaysBefore ?? Date(),
			dateChangedComparedToPreviousSubmission: false
		)
		store.currentENFRiskExposureMetadata = currentENFRiskExposureMetadata
		store.currentCheckinRiskExposureMetadata = currentCheckinRiskExposureMetadata
		
		XCTAssertNil(store.previousENFRiskExposureMetadata)
		XCTAssertNil(store.previousCheckinRiskExposureMetadata)
		
		// WHEN
		analyticsSubmitter.triggerSubmitData(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case .failure:
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		
		/// Check that store is setup correctly after successful submission
		XCTAssertNil(store.currentENFRiskExposureMetadata)
		XCTAssertNil(store.currentCheckinRiskExposureMetadata)
		XCTAssertNil(store.previousENFRiskExposureMetadata)
		XCTAssertNil(store.previousCheckinRiskExposureMetadata)
		
		let someTimeAgo = Calendar.current.date(byAdding: .second, value: -20, to: Date())
		let someTimeAgoTimeRange = try XCTUnwrap(someTimeAgo)...Date()
		XCTAssertFalse(someTimeAgoTimeRange.contains(try XCTUnwrap(store.lastSubmissionAnalytics)))
	}
	
	// MARK: - Conversion to protobuf
	
	func testGIVEN_AgeGroup_WHEN_Converting_THEN_ProtobufAgeGroupIsReturned() {
		// GIVEN
		let ageGroup: AgeGroup = .ageBetween30And59
		
		// WHEN
		let expectation = ageGroup.protobuf
		
		// THEN
		XCTAssertEqual(expectation, SAP_Internal_Ppdd_PPAAgeGroup.ageGroup30To59)
	}
	
	func testGIVEN_FederalState_WHEN_Converting_THEN_ProtobufFederalStateIsReturned() {
		// GIVEN
		let federalState: FederalStateName = .hessen
		
		// WHEN
		let expectation = federalState.protobuf
		
		// THEN
		XCTAssertEqual(expectation, SAP_Internal_Ppdd_PPAFederalState.federalStateHe)
	}
	
	func testGIVEN_RiskLevel_WHEN_Converting_THEN_ProtobufRiskLevelIsReturned() {
		// GIVEN
		let riskLevel: RiskLevel = .high
		
		// WHEN
		let expectation = riskLevel.protobuf
		
		// THEN
		XCTAssertEqual(expectation, SAP_Internal_Ppdd_PPARiskLevel.riskLevelHigh)
	}
	
	// MARK: - ProtoBuf Mapping
	
	func testGatherUserMetadata() {
		let store = MockTestStore()
		let analyticsSubmitter = createMockSubmitter(with: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		
		// Setup Collector
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
		// collect userMetadata
		let state: FederalStateName = .badenWürttemberg
		let ageGroup: AgeGroup = .ageBelow29
		let administrativeUnit = 4
		
		store.userData = UserMetadata(
			federalState: state,
			administrativeUnit: administrativeUnit,
			ageGroup: ageGroup)
		
		let protobuf = analyticsSubmitter.gatherUserMetadata()
		XCTAssertNotNil(store.userMetadata, "userMetadata should be allocated")
		
		XCTAssertEqual(protobuf.federalState, state.protobuf, "Wrong Registration date")
		XCTAssertEqual(protobuf.ageGroup, ageGroup.protobuf, "Wrong Registration date")
		XCTAssertEqual(protobuf.administrativeUnit, Int32(administrativeUnit), "Wrong Registration date")
	}
	
	func testGatherClientMetadata() {
		
		let eTag = "123"
		let store = MockTestStore()
		store.appConfigMetadata = AppConfigMetadata(
			lastAppConfigETag: eTag,
			lastAppConfigFetch: Date(),
			appConfig: SAP_Internal_V2_ApplicationConfigurationIOS()
		)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		
		let analyticsSubmitter = createMockSubmitter(with: store)
		let clientMetadata = ClientMetadata(etag: eTag)
		let protobuf = analyticsSubmitter.gatherClientMetadata()
		
		XCTAssertNotNil(store.clientMetadata, "clientMetadata should be allocated")
		XCTAssertEqual(protobuf.appConfigEtag, eTag, "eTag not equal clientMetaData eTag")
		XCTAssertEqual(protobuf.cwaVersion, clientMetadata.cwaVersion?.protobuf, "cwaVersion not equal clientMetaData cwaVersion")
		XCTAssertEqual(protobuf.iosVersion, clientMetadata.iosVersion.protobuf, "iosVersion not equal clientMetaData iosVersion")
	}
	
	func testGatherTestResultMetadata() {
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)
		
		// Setup Collector
		
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
		// collect current exposure windows, it imitates the collection which will happen in risk provider
		
		Analytics.collect(.testResultMetadata(.collectCurrentExposureWindows(mappedExposureWindows)))
		
		let mappedSubmissionExposureWindowsAtTestRegistration: [SubmissionExposureWindow] = mappedExposureWindows.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}
		
		// collect testResultMetadata
		
		let today = Date()
		let differenceBetweenMostRecentRiskDateAndRegistrationDate = 5
		let registrationDate = Calendar.current.date(byAdding: .day, value: -10, to: today) ?? Date()
		guard let mostRecentDayWithRisk = Calendar.current.date(byAdding: .day, value: -differenceBetweenMostRecentRiskDateAndRegistrationDate, to: registrationDate) else {
			XCTFail("Could not create mostRecentDayWithRisk")
			return
		}
		let dateOfRiskChangeToHigh = Calendar.current.date(byAdding: .day, value: -12, to: today)
		let registrationToken = "123"
		let testResult: TestResult = .negative
		let riskLevel: RiskLevel = .high
		let differenceInHoursBetweenChangeToHighRiskAndRegistrationDate = Calendar.current.dateComponents([.hour], from: dateOfRiskChangeToHigh ?? Date(), to: registrationDate).hour
		let differenceInHoursBetweenRegistrationDateAndTestResult = Calendar.current.dateComponents([.hour], from: registrationDate, to: today).hour
		
		let enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 6,
			minimumDistinctEncountersWithHighRisk: 2,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDayWithRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: 0,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
		
		let checkinIdWithRisk = CheckinIdWithRisk(
			checkinId: 007,
			riskLevel: riskLevel
		)
		
		let checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [mostRecentDayWithRisk: [checkinIdWithRisk]],
			riskLevelPerDate: [mostRecentDayWithRisk: riskLevel]
		)
		
		store.enfRiskCalculationResult = enfRiskCalculationResult
		store.dateOfConversionToENFHighRisk = dateOfRiskChangeToHigh
		store.checkinRiskCalculationResult = checkinRiskCalculationResult
		store.dateOfConversionToCheckinHighRisk = dateOfRiskChangeToHigh
		
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, registrationToken, .pcr)))
		XCTAssertEqual(store.pcrTestResultMetadata?.testRegistrationDate, registrationDate, "Wrong Registration date")
		
		XCTAssertEqual(store.pcrTestResultMetadata?.riskLevelAtTestRegistration, riskLevel, "Wrong enf Risk Level")
		XCTAssertEqual(store.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, differenceBetweenMostRecentRiskDateAndRegistrationDate, "Wrong number of days with this enf risk level")
		XCTAssertEqual(store.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, differenceInHoursBetweenChangeToHighRiskAndRegistrationDate, "Wrong difference hoursSinceHighRiskWarningAtTestRegistration")
		
		XCTAssertEqual(store.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration, riskLevel, "Wrong checkin Risk Level")
		XCTAssertEqual(store.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, differenceBetweenMostRecentRiskDateAndRegistrationDate, "Wrong number of days with this checkin risk level")
		XCTAssertEqual(store.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, differenceInHoursBetweenChangeToHighRiskAndRegistrationDate, "Wrong difference hoursSinceCheckinHighRiskWarningAtTestRegistration")
		XCTAssertEqual(store.pcrTestResultMetadata?.exposureWindowsAtTestRegistration, mappedSubmissionExposureWindowsAtTestRegistration, "Wrong exposure windows")
		
		// update current exposure windows, it imitates the update which will happen in risk provider
		
		Analytics.collect(.testResultMetadata(.collectCurrentExposureWindows(updatedMappedExposureWindows)))
		
		let mappedSubmissionExposureWindowsUntilTestResult: [SubmissionExposureWindow] = mappedExposureWindowsUntilTestResult.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}
		
		Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken, .pcr)))
		XCTAssertEqual(store.pcrTestResultMetadata?.testResult, testResult, "Wrong TestResult")
		XCTAssertEqual(store.pcrTestResultMetadata?.hoursSinceTestRegistration, differenceInHoursBetweenRegistrationDateAndTestResult, "Wrong difference hoursSinceTestRegistration")
		XCTAssertEqual(store.pcrTestResultMetadata?.exposureWindowsUntilTestResult, mappedSubmissionExposureWindowsUntilTestResult, "Wrong exposure windows")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherTestResultMetadata(for: .pcr)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.protobuf,
			protobuf.testResult,
			"Wrong testResult protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.hoursSinceTestRegistration,
			Int(protobuf.hoursSinceTestRegistration),
			"Wrong hoursSinceTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.riskLevelAtTestRegistration?.protobuf,
			protobuf.riskLevelAtTestRegistration,
			"Wrong riskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			Int(protobuf.daysSinceMostRecentDateAtRiskLevelAtTestRegistration),
			"Wrong daysSinceMostRecentDateAtRiskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration,
			Int(protobuf.hoursSinceHighRiskWarningAtTestRegistration),
			"Wrong hoursSinceHighRiskWarningAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.checkinRiskLevelAtTestRegistration?.protobuf,
			protobuf.ptRiskLevelAtTestRegistration,
			"Wrong riskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration,
			Int(protobuf.ptDaysSinceMostRecentDateAtRiskLevelAtTestRegistration),
			"Wrong daysSinceMostRecentDateAtRiskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.pcrTestResultMetadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration,
			Int(protobuf.ptHoursSinceHighRiskWarningAtTestRegistration),
			"Wrong hoursSinceHighRiskWarningAtTestRegistration protobuf mapping"
		)
	}
	
	func testGatherRiskExposureMetadata() {
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)
		
		// Setup Collector
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
		// Collect RiskExposureMetadata
		let numberOfDaysWithHighRisk = 25
		let riskLevel: RiskLevel = .high
		guard let mostRecentDayWithRisk = Calendar.current.date(byAdding: .day, value: -5, to: Date()) else {
			XCTFail("Could not create mostRecentDayWithRisk")
			return
		}
		
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 6,
			minimumDistinctEncountersWithHighRisk: 2,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDayWithRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: numberOfDaysWithHighRisk,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
		
		let checkinIdWithRisk = CheckinIdWithRisk(
			checkinId: 007,
			riskLevel: riskLevel
		)
		
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [mostRecentDayWithRisk: [checkinIdWithRisk]],
			riskLevelPerDate: [mostRecentDayWithRisk: riskLevel]
		)
		
		Analytics.collect(.riskExposureMetadata(.update))
		XCTAssertNotNil(store.currentENFRiskExposureMetadata, "riskMetadata should be allocated")
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevel, riskLevel, "Wrong riskLevel")
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false, "should be false as this is the first submission")
		XCTAssertEqual(store.currentENFRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, true, "should be true as this is the first submission")
		
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevel, riskLevel, "Wrong riskLevel")
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false, "should be false as this is the first submission")
		XCTAssertEqual(store.currentCheckinRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, false, "should be false as this is the first submission")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherExposureRiskMetadata()
		XCTAssertFalse(protobuf.isEmpty, "There should be at least one item in the array")
		XCTAssertEqual(protobuf.first?.riskLevel, riskLevel.protobuf, "Wrong riskLevel mapped")
		XCTAssertEqual(protobuf.first?.riskLevelChangedComparedToPreviousSubmission, store.currentENFRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, "Wrong riskLevelChangedComparedToPreviousSubmission")
		XCTAssertEqual(protobuf.first?.mostRecentDateAtRiskLevel, formatToUnixTimestamp(for: store.currentENFRiskExposureMetadata?.mostRecentDateAtRiskLevel), "Wrong mostRecentDateAtRiskLevel")
		XCTAssertEqual(protobuf.first?.dateChangedComparedToPreviousSubmission, store.currentENFRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, "Wrong dateChangedComparedToPreviousSubmission")
		
		XCTAssertEqual(protobuf.first?.ptRiskLevel, riskLevel.protobuf, "Wrong riskLevel mapped")
		XCTAssertEqual(protobuf.first?.ptRiskLevelChangedComparedToPreviousSubmission, store.currentCheckinRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, "Wrong riskLevelChangedComparedToPreviousSubmission")
		XCTAssertEqual(protobuf.first?.ptMostRecentDateAtRiskLevel, formatToUnixTimestamp(for: store.currentCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel), "Wrong mostRecentDateAtRiskLevel")
		XCTAssertEqual(protobuf.first?.ptDateChangedComparedToPreviousSubmission, store.currentCheckinRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, "Wrong dateChangedComparedToPreviousSubmission")
	}
	
	func testGatherRiskExposureMetadataWithoutMostRecentDate() {
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)
		
		// Setup Collector
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
		// Collect RiskExposureMetadata
		let numberOfDaysWithHighRisk = 25
		let riskLevel: RiskLevel = .high
		guard let mostRecentDayWithRisk = Calendar.current.date(byAdding: .day, value: -5, to: Date()) else {
			XCTFail("Could not create mostRecentDayWithRisk")
			return
		}
		
		store.enfRiskCalculationResult = ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 6,
			minimumDistinctEncountersWithHighRisk: 2,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: nil,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: numberOfDaysWithHighRisk,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)
		
		let checkinIdWithRisk = CheckinIdWithRisk(
			checkinId: 007,
			riskLevel: riskLevel
		)
		
		store.checkinRiskCalculationResult = CheckinRiskCalculationResult(
			calculationDate: Date(),
			checkinIdsWithRiskPerDate: [mostRecentDayWithRisk: [checkinIdWithRisk]],
			riskLevelPerDate: [:]
		)
		
		Analytics.collect(.riskExposureMetadata(.update))
		XCTAssertNil(store.currentENFRiskExposureMetadata?.mostRecentDateAtRiskLevel, "should be nil as it was not set")
		XCTAssertNil(store.currentCheckinRiskExposureMetadata?.mostRecentDateAtRiskLevel, "should be nil as it was not set")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherExposureRiskMetadata()
		XCTAssertFalse(protobuf.isEmpty, "There should be at least one item in the array")
		
		XCTAssertEqual(protobuf.first?.mostRecentDateAtRiskLevel, -1, "Wrong mostRecentDateAtRiskLevel")
		XCTAssertEqual(protobuf.first?.ptMostRecentDateAtRiskLevel, -1, "Wrong mostRecentDateAtRiskLevel")
	}
	
	func testGatherExposureWindowsMetadata() {
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)
		
		// Setup Collector
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
		// collect exposureWindowsMetadata
		Analytics.collect(.exposureWindowsMetadata(.collectExposureWindows(mappedExposureWindows)))
		let mappedSubmissionExposureWindows: [SubmissionExposureWindow] = mappedExposureWindows.map {
			SubmissionExposureWindow(
				exposureWindow: $0.exposureWindow,
				transmissionRiskLevel: $0.transmissionRiskLevel,
				normalizedTime: $0.normalizedTime,
				hash: generateSHA256($0.exposureWindow),
				date: $0.date
			)
		}
		
		let metadata = store.exposureWindowsMetadata
		XCTAssertEqual(metadata?.newExposureWindowsQueue, mappedSubmissionExposureWindows, "Wrong newExposureWindowsQueue")
		XCTAssertEqual(metadata?.reportedExposureWindowsQueue, mappedSubmissionExposureWindows, "Wrong reportedExposureWindowsQueue")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherNewExposureWindows()
		
		for index in protobuf.indices {
			XCTAssertEqual(protobuf[index].normalizedTime, mappedSubmissionExposureWindows[index].normalizedTime, "Wrong normalizedTime")
			XCTAssertEqual(protobuf[index].transmissionRiskLevel, Int32(mappedSubmissionExposureWindows[index].transmissionRiskLevel), "Wrong transmissionRiskLevel")
			XCTAssertEqual(protobuf[index].exposureWindow.calibrationConfidence, Int32(mappedSubmissionExposureWindows[index].exposureWindow.calibrationConfidence.rawValue), "Wrong calibrationConfidence")
			XCTAssertEqual(protobuf[index].exposureWindow.infectiousness, mappedSubmissionExposureWindows[index].exposureWindow.infectiousness.protobuf, "Wrong infectiousness")
			XCTAssertEqual(protobuf[index].exposureWindow.reportType, mappedSubmissionExposureWindows[index].exposureWindow.reportType.protobuf, "Wrong reportType")
			XCTAssertEqual(protobuf[index].exposureWindow.date, Int64(mappedSubmissionExposureWindows[index].exposureWindow.date.timeIntervalSince1970), "Wrong date")
			XCTAssertEqual(protobuf[index].exposureWindow.scanInstances.count, mappedSubmissionExposureWindows[index].exposureWindow.scanInstances.count, "Wrong scanInstances.count")
			
			for (scanInstancesIndex, scanInstance)  in protobuf[index].exposureWindow.scanInstances.enumerated() {
				XCTAssertEqual(scanInstance.minAttenuation, Int32(mappedSubmissionExposureWindows[index].exposureWindow.scanInstances[scanInstancesIndex].minAttenuation), "Wrong minAttenuation")
				XCTAssertEqual(scanInstance.secondsSinceLastScan, Int32(mappedSubmissionExposureWindows[index].exposureWindow.scanInstances[scanInstancesIndex].secondsSinceLastScan), "Wrong secondsSinceLastScan")
				XCTAssertEqual(scanInstance.typicalAttenuation, Int32(mappedSubmissionExposureWindows[index].exposureWindow.scanInstances[scanInstancesIndex].typicalAttenuation), "Wrong typicalAttenuation")
			}
		}
	}
	
	func testGatherKeySubmissionMetadata() {
		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let restServiceProvider = RestServiceProviderStub(
			results: [
				.success(RegistrationTokenModel(registrationToken: "fake")),
				.success(SubmissionTANModel(submissionTAN: "fake"))
			]
		)
		
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)
		
		let coronaTestService = CoronaTestService(
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
					rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
				),
				recycleBin: .fake()
			),
			recycleBin: .fake(),
			badgeWrapper: .fake()
		)
		coronaTestService.registerPCRTest(
			teleTAN: "tele-tan",
			isSubmissionConsentGiven: true,
			completion: { _ in }
		)
		
		let fiveHoursBefore = Calendar.current.date(byAdding: .hour, value: -5, to: Date())
		coronaTestService.pcrTest?.finalTestResultReceivedDate = fiveHoursBefore ?? Date()
		
		Analytics.setupMock(
			store: store,
			submitter: analyticsSubmitter,
			coronaTestService: coronaTestService
		)
		
		// collect keySubmissionMetadata
		let keySubmissionMetadata = KeySubmissionMetadata(
			submitted: false,
			submittedInBackground: false,
			submittedAfterCancel: false,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: true,
			hoursSinceTestResult: 0,
			hoursSinceTestRegistration: 0,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: -1,
			hoursSinceHighRiskWarningAtTestRegistration: -1,
			submittedWithTeleTAN: false,
			submittedAfterRapidAntigenTest: false,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: true
		)
		
		let lastScreen: LastSubmissionFlowScreen = .submissionFlowScreenOther
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(lastScreen, .pcr)))
		Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(true, .pcr)))
		
		let metadata = store.pcrKeySubmissionMetadata
		XCTAssertNotNil(metadata, "pcrKeySubmissionMetadata should be allocated")
		XCTAssertEqual(metadata?.submitted, true, "Wrong pcrKeySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedInBackground, true, "Wrong pcrKeySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedAfterCancel, true, "Wrong pcrKeySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedAfterSymptomFlow, true, "Wrong pcrKeySubmissionMetadata")
		XCTAssertEqual(metadata?.lastSubmissionFlowScreen, lastScreen, "Wrong pcrKeySubmissionMetadata")
		XCTAssertEqual(metadata?.advancedConsentGiven, true, "Wrong pcrKeySubmissionMetadata")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherKeySubmissionMetadata(for: .pcr)
		XCTAssertEqual(protobuf?.submitted, metadata?.submitted, "Wrong submitted")
		XCTAssertEqual(protobuf?.submittedInBackground, metadata?.submittedInBackground, "Wrong submittedInBackground")
		XCTAssertEqual(protobuf?.submittedAfterCancel, metadata?.submittedAfterCancel, "Wrong submittedAfterCancel")
		XCTAssertEqual(protobuf?.submittedAfterSymptomFlow, metadata?.submittedAfterSymptomFlow, "Wrong submittedAfterSymptomFlow")
		XCTAssertEqual(protobuf?.submittedWithCheckIns, .tsbTrue)
		XCTAssertEqual(protobuf?.advancedConsentGiven, metadata?.advancedConsentGiven, "Wrong advancedConsentGiven")
		XCTAssertEqual(protobuf?.lastSubmissionFlowScreen, metadata?.lastSubmissionFlowScreen?.protobuf, "Wrong lastSubmissionFlowScreen")
		XCTAssertEqual(protobuf?.hoursSinceTestResult, metadata?.hoursSinceTestResult, "Wrong hoursSinceTestResult")
		XCTAssertEqual(protobuf?.hoursSinceTestRegistration, metadata?.hoursSinceTestRegistration, "Wrong hoursSinceTestRegistration")
		XCTAssertEqual(protobuf?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "Wrong daysSinceMostRecentDateAtRiskLevelAtTestRegistration")
		XCTAssertEqual(protobuf?.hoursSinceHighRiskWarningAtTestRegistration, metadata?.hoursSinceHighRiskWarningAtTestRegistration, "Wrong hoursSinceHighRiskWarningAtTestRegistration")
		XCTAssertEqual(protobuf?.ptDaysSinceMostRecentDateAtRiskLevelAtTestRegistration, metadata?.daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration, "Wrong daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration")
		XCTAssertEqual(protobuf?.ptHoursSinceHighRiskWarningAtTestRegistration, metadata?.hoursSinceCheckinHighRiskWarningAtTestRegistration, "Wrong hoursSinceCheckinHighRiskWarningAtTestRegistration")
		XCTAssertNotEqual(protobuf?.submittedWithTeleTan, store.antigenKeySubmissionMetadata?.submittedWithTeleTAN, "Wrong submittedWithTeleTan")
	}
	
	// MARK: - Helpers
	
	private func createMockSubmitter(with store: MockTestStore) -> PPAnalyticsSubmitter {
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
#if targetEnvironment(simulator)
		let deviceCheck = PPACDeviceCheckMock(true, deviceToken: "iPhone")
#else
		let deviceCheck = PPACDeviceCheck()
#endif
		return PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfigurationProvider,
				healthCertificateService: HealthCertificateService(
					store: store,
					dccSignatureVerifier: DCCSignatureVerifyingStub(),
					dscListProvider: MockDSCListProvider(),
					client: client,
					appConfiguration: appConfigurationProvider,
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(restServiceProvider: .fake())
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			ppacService: PPACService(store: store, deviceCheck: deviceCheck)
		)
	}
	
	private func generateSHA256(_ window: ExposureWindow) -> String? {
		let encoder = JSONEncoder()
		do {
			let windowData = try encoder.encode(window)
			return windowData.sha256String()
		} catch {
			Log.error("ExposureWindow Encoding error", log: .ppa, error: error)
		}
		return nil
	}
	
	private func formatToUnixTimestamp(for date: Date?) -> Int64 {
		guard let date = date else {
			Log.warning("mostRecentDate is nil", log: .ppa)
			return -1
		}
		return Int64(date.timeIntervalSince1970)
	}
	
	private var mappedExposureWindows: [RiskCalculationExposureWindow] = [
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .high,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .medium,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		)
	]
	
	private var updatedMappedExposureWindows: [RiskCalculationExposureWindow] = [
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .high,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .medium,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .standard,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .none,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		)
	]
	
	private var mappedExposureWindowsUntilTestResult: [RiskCalculationExposureWindow] = [
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .standard,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		),
		RiskCalculationExposureWindow(
			exposureWindow: ExposureWindow(
				calibrationConfidence: .low,
				date: Date(timeIntervalSinceReferenceDate: -123456789.0),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .none,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		)
	]
}
