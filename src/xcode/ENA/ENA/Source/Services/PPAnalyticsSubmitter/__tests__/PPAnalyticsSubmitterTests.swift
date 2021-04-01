////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class PPAnalyticsSubmitterTests: XCTestCase {

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
			case let .failure(error):
				XCTFail("Test should not fail. Received error: \(error)")
			}
		})

		// THEN
		waitForExpectations(timeout: .medium)
		
		/// Check that store is setup correctly after successful submission
		XCTAssertEqual(store.previousRiskExposureMetadata, currentRiskExposureMetadata)
		XCTAssertNil(store.currentRiskExposureMetadata)
		XCTAssertNil(store.testResultMetadata)
		XCTAssertNil(store.keySubmissionMetadata)
		XCTAssertNil(store.exposureWindowsMetadata?.newExposureWindowsQueue)
		
		/// Since the Date is super precise we have to be fuzzy here, and since we know our CI lets me a lot fuzzy here.
		let someTimeAgo = Calendar.current.date(byAdding: .second, value: -20, to: Date())
		let someTimeAgoTimeRange = try XCTUnwrap(someTimeAgo)...Date()
		XCTAssertTrue(someTimeAgoTimeRange.contains(try XCTUnwrap(store.lastSubmissionAnalytics)))
		
	}

	// MARK: - Failures

	func testGIVEN_SubmissionIsTriggered_WHEN_UserConsentIsMissing_THEN_UserConsentErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
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
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .probibilityError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_SubmissionWas2HoursAgo_THEN_Submission23hoursErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
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
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .submission23hoursError)
	}

	func testGIVEN_SubmissionIsTriggered_WHEN_OnboardingWas2HoursAgo_THEN_OnboardingErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
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
		waitForExpectations(timeout: .medium)
		XCTAssertEqual(ppasError, .ppacError(.generationFailed))
	}
	
	func testGIVEN_SubmissionIsTriggered_WHEN_SeveralTimes_THEN_SubmissionInProgressErrorIsReturned() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
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
		
		// collect testResultMetadata
		
		let today = Date()
		let differenceBetweenMostRecentRiskDateAndRegistrationDate = 5
		let registrationDate = Calendar.current.date(byAdding: .day, value: -10, to: today) ?? Date()
		let mostRecentDayWithRisk = Calendar.current.date(byAdding: .day, value: -differenceBetweenMostRecentRiskDateAndRegistrationDate, to: registrationDate)
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
		store.enfRiskCalculationResult = enfRiskCalculationResult
		store.dateOfConversionToHighRisk = dateOfRiskChangeToHigh
		
		Analytics.collect(.testResultMetadata(.registerNewTestMetadata(registrationDate, registrationToken)))
		XCTAssertEqual(store.testResultMetadata?.testRegistrationDate, registrationDate, "Wrong Registration date")
		XCTAssertEqual(store.testResultMetadata?.riskLevelAtTestRegistration, riskLevel, "Wrong Risk Level")
		XCTAssertEqual(store.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, differenceBetweenMostRecentRiskDateAndRegistrationDate, "Wrong number of days with this risk level")
		XCTAssertEqual(store.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration, differenceInHoursBetweenChangeToHighRiskAndRegistrationDate, "Wrong difference hoursSinceHighRiskWarningAtTestRegistration")

		Analytics.collect(.testResultMetadata(.updateTestResult(testResult, registrationToken)))
		XCTAssertEqual(store.testResultMetadata?.testResult, testResult, "Wrong TestResult")
		XCTAssertEqual(store.testResultMetadata?.hoursSinceTestRegistration, differenceInHoursBetweenRegistrationDateAndTestResult, "Wrong difference hoursSinceTestRegistration")

		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherTestResultMetadata().first
		XCTAssertEqual(
			store.testResultMetadata?.testResult?.protobuf,
			protobuf?.testResult,
			"Wrong testResult protobuf mapping"
		)
		XCTAssertEqual(
			store.testResultMetadata?.hoursSinceTestRegistration,
			Int(protobuf?.hoursSinceTestRegistration ?? -1),
			"Wrong hoursSinceTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.testResultMetadata?.riskLevelAtTestRegistration?.protobuf,
			protobuf?.riskLevelAtTestRegistration,
			"Wrong riskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.testResultMetadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration,
			Int(protobuf?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration ?? -1),
			"Wrong daysSinceMostRecentDateAtRiskLevelAtTestRegistration protobuf mapping"
		)
		XCTAssertEqual(
			store.testResultMetadata?.hoursSinceHighRiskWarningAtTestRegistration,
			Int(protobuf?.hoursSinceHighRiskWarningAtTestRegistration ?? -1),
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
		let numberOfDaysWithHightRisk = 25
		let riskLevel: RiskLevel = .high
		let mostRecentDayWithRisk = Calendar.current.date(byAdding: .day, value: -5, to: Date())

		let riskCalculationResult = ENFRiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: 6,
			minimumDistinctEncountersWithHighRisk: 2,
			mostRecentDateWithLowRisk: nil,
			mostRecentDateWithHighRisk: mostRecentDayWithRisk,
			numberOfDaysWithLowRisk: 0,
			numberOfDaysWithHighRisk: numberOfDaysWithHightRisk,
			calculationDate: Date(),
			riskLevelPerDate: [:],
			minimumDistinctEncountersWithHighRiskPerDate: [:]
		)

		Analytics.collect(.riskExposureMetadata(.updateRiskExposureMetadata(riskCalculationResult)))
		XCTAssertNotNil(store.currentRiskExposureMetadata, "riskMetadata should be allocated")
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevel, riskLevel, "Wrong riskLevel")
		XCTAssertEqual(store.currentRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, false, "should be false as this is the first submission")
		XCTAssertEqual(store.currentRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, false, "should be false as this is the first submission")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherExposureRiskMetadata()
		XCTAssertFalse(protobuf.isEmpty, "There should be at least one item in the array")
		XCTAssertEqual(protobuf.first?.riskLevel, riskLevel.protobuf, "Wrong riskLevel mapped")
		XCTAssertEqual(protobuf.first?.riskLevelChangedComparedToPreviousSubmission, store.currentRiskExposureMetadata?.riskLevelChangedComparedToPreviousSubmission, "Wrong riskLevelChangedComparedToPreviousSubmission")
		XCTAssertEqual(protobuf.first?.mostRecentDateAtRiskLevel, formatToUnixTimestamp(for: store.currentRiskExposureMetadata?.mostRecentDateAtRiskLevel), "Wrong mostRecentDateAtRiskLevel")
		XCTAssertEqual(protobuf.first?.dateChangedComparedToPreviousSubmission, store.currentRiskExposureMetadata?.dateChangedComparedToPreviousSubmission, "Wrong dateChangedComparedToPreviousSubmission")
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
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		let analyticsSubmitter = createMockSubmitter(with: store)

		// Setup Collector
		Analytics.setupMock(store: store, submitter: analyticsSubmitter)
		
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
			hoursSinceHighRiskWarningAtTestRegistration: -1
		)
		
		let lastScreen: LastSubmissionFlowScreen = .submissionFlowScreenOther
		Analytics.collect(.keySubmissionMetadata(.create(keySubmissionMetadata)))
		Analytics.collect(.keySubmissionMetadata(.submitted(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedInBackground(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterCancel(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedAfterSymptomFlow(true)))
		Analytics.collect(.keySubmissionMetadata(.submittedWithTeletan(false)))
		Analytics.collect(.keySubmissionMetadata(.lastSubmissionFlowScreen(lastScreen)))
		Analytics.collect(.keySubmissionMetadata(.advancedConsentGiven(true)))
		Analytics.collect(.keySubmissionMetadata(.hoursSinceTestResult(5)))
		Analytics.collect(.keySubmissionMetadata(.keySubmissionHoursSinceTestRegistration(9)))
		Analytics.collect(.keySubmissionMetadata(.daysSinceMostRecentDateAtRiskLevelAtTestRegistration(74)))
		Analytics.collect(.keySubmissionMetadata(.hoursSinceHighRiskWarningAtTestRegistration(53)))

		let metadata = store.keySubmissionMetadata
		XCTAssertNotNil(metadata, "keySubmissionMetadata should be allocated")
		XCTAssertEqual(metadata?.submitted, true, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedInBackground, true, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedAfterCancel, true, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.submittedAfterSymptomFlow, true, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.lastSubmissionFlowScreen, lastScreen, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.advancedConsentGiven, true, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.hoursSinceTestResult, 5, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.hoursSinceTestRegistration, 9, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, 74, "Wrong keySubmissionMetadata")
		XCTAssertEqual(metadata?.hoursSinceHighRiskWarningAtTestRegistration, 53, "Wrong keySubmissionMetadata")
		
		// Mapping to protobuf
		let protobuf = analyticsSubmitter.gatherKeySubmissionMetadata().first
		XCTAssertEqual(protobuf?.submitted, metadata?.submitted, "Wrong submitted")
		XCTAssertEqual(protobuf?.submittedInBackground, metadata?.submittedInBackground, "Wrong submittedInBackground")
		XCTAssertEqual(protobuf?.submittedAfterCancel, metadata?.submittedAfterCancel, "Wrong submittedAfterCancel")
		XCTAssertEqual(protobuf?.submittedAfterSymptomFlow, metadata?.submittedAfterSymptomFlow, "Wrong submittedAfterSymptomFlow")
		XCTAssertEqual(protobuf?.advancedConsentGiven, metadata?.advancedConsentGiven, "Wrong advancedConsentGiven")
		XCTAssertEqual(protobuf?.lastSubmissionFlowScreen, metadata?.lastSubmissionFlowScreen?.protobuf, "Wrong lastSubmissionFlowScreen")
		XCTAssertEqual(protobuf?.hoursSinceTestResult, metadata?.hoursSinceTestResult, "Wrong hoursSinceTestResult")
		XCTAssertEqual(protobuf?.hoursSinceTestRegistration, metadata?.hoursSinceTestRegistration, "Wrong hoursSinceTestRegistration")
		XCTAssertEqual(protobuf?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, metadata?.daysSinceMostRecentDateAtRiskLevelAtTestRegistration, "Wrong daysSinceMostRecentDateAtRiskLevelAtTestRegistration")
		XCTAssertEqual(protobuf?.hoursSinceHighRiskWarningAtTestRegistration, metadata?.hoursSinceHighRiskWarningAtTestRegistration, "Wrong hoursSinceHighRiskWarningAtTestRegistration")
		XCTAssertNotEqual(protobuf?.submittedWithTeleTan, store.submittedWithQR, "Wrong submittedWithTeleTan")
	}
	
	// MARK: - Helpers
	
	private func createMockSubmitter(with store: MockTestStore) -> PPAnalyticsSubmitter {
		let client = ClientMock()
		let config = SAP_Internal_V2_ApplicationConfigurationIOS()
		let appConfigurationProvider = CachedAppConfigurationMock(with: config)
		return PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfigurationProvider
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
				date: Date(),
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
				date: Date(),
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
				date: Date(),
				reportType: .confirmedClinicalDiagnosis,
				infectiousness: .high,
				scanInstances: []
			),
			configuration: RiskCalculationConfiguration(
				from: SAP_Internal_V2_ApplicationConfigurationIOS().riskCalculationParameters)
		)
	]
}
