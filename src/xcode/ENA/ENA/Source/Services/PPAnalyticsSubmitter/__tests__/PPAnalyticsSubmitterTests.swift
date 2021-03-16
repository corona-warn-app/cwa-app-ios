////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPAnalyticsSubmitterTests: XCTestCase {

	// MARK: - Success

	func testGIVEN_SubmissionIsTriggered_WHEN_EverythingIsGiven_THEN_Success() throws {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always succeed
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
		)

		let expectation = self.expectation(description: "completion handler is called without an error")

		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.dateOfAcceptedPrivacyNotice = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		store.lastAppReset = Calendar.current.date(byAdding: .day, value: -5, to: Date())
		let ppacToken = PPACToken(apiToken: "FakeApiToken", deviceToken: "FakeDeviceToken")
		
		let currentRiskExposureMetadata = store.currentRiskExposureMetadata

		// WHEN
		analyticsSubmitter.triggerSubmitData(ppacToken: ppacToken, completion: { result in
			switch result {
			case .success:
				expectation.fulfill()
			case .failure:
				XCTFail("Test should not fail")
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		
		
		/// Check that store is setup correctly after successful submission
		XCTAssertEqual(store.previousRiskExposureMetadata, currentRiskExposureMetadata)
		XCTAssertNil(store.currentRiskExposureMetadata)
		XCTAssertNil(store.testResultMetadata)
		XCTAssertNil(store.keySubmissionMetadata)
		XCTAssertNil(store.exposureWindowsMetadata?.newExposureWindowsQueue)
		
		/// Since the Date is super precise we have to be fuzzy here, and since we know our CI lets me a lot fuzzy here.
		let tenSecondsAgo = Calendar.current.date(byAdding: .second, value: -10, to: Date())
		let lastTenSeconds = try XCTUnwrap(tenSecondsAgo)...Date()
		XCTAssertTrue(lastTenSeconds.contains(try XCTUnwrap(store.lastSubmissionAnalytics)))
		
	}

	// MARK: - Failures

	func testGIVEN_SubmissionIsTriggered_WHEN_UserConsentIsMissing_THEN_UserConsentErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .userConsentError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_AppConfigIsMissing_THEN_ProbibilityErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .probibilityError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_ProbabilityIsLow_THEN_ProbibilityErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		// probability will always fail
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = -1
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .probibilityError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_SubmissionWas2HoursAgo_THEN_Submission23hoursErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .submission23hoursError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_OnboardingWas2HoursAgo_THEN_OnboardingErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
		)

		let expectation = self.expectation(description: "completion handler is called with an error")
		store.lastSubmissionAnalytics = Calendar.current.date(byAdding: .day, value: -5, to: Date())
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .onboardingError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_AppResetWas2HoursAgo_THEN_AppResetErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .appResetError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_PpacCouldNotAuthorize_THEN_PpacErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let client = ClientMock()
		var config = SAP_Internal_V2_ApplicationConfigurationIOS()
		config.privacyPreservingAnalyticsParameters.common.probabilityToSubmit = 3
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
				XCTFail("Test should not success")
			case let .failure(error):
				ppasError = error
				expectation.fulfill()
			}
		})

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(ppasError, .ppacError(.generationFailed))
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_SeveralTimes_THEN_SubmissionInProgressErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		Analytics.setupMock(store: store)
		let client = ClientMock()
		let appConfigurationProvider = CachedAppConfigurationMock()
		let analyticsSubmitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
		)

		let expectation = self.expectation(description: "completion handler is called with an error")
		expectation.expectedFulfillmentCount = 2

		// WHEN
		var ppasErrors: [PPASError] = []
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasErrors.append(error)
				expectation.fulfill()
			}
		})
		
		analyticsSubmitter.triggerSubmitData(ppacToken: nil, completion: { result in
			switch result {
			case .success:
				XCTFail("Test should not success")
			case let .failure(error):
				ppasErrors.append(error)
				expectation.fulfill()
			}
		})
		
		// THEN
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasErrors.count, 2)
		XCTAssertTrue(ppasErrors.contains(.submissionInProgress))
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
}
