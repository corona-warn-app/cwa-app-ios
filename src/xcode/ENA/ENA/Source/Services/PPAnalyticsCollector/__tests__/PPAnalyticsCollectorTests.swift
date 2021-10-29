////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPAnalyticsCollectorTests: CWATestCase {
	
	func testGIVEN_NotSetupAnalytics_WHEN_SomethingIsLogged_THEN_NothingIsLogged() {
		// GIVEN
		let store = MockTestStore()
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.collect(.userData(.create(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertNil(store.userMetadata?.ageGroup)
	}
	
	func testGIVEN_UserConsentNotGiven_WHEN_SomethingIsLogged_THEN_LoggingIsNotAllowed() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.collect(.userData(.create(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertNil(store.userMetadata?.ageGroup)
	}
	
	func testGIVEN_UserConsentGiven_WHEN_SomethingIsLogged_THEN_LoggingIsAllowed() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.collect(.userData(.create(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertEqual(store.userMetadata?.ageGroup, .ageBelow29)
	}
	
	func testGIVEN_SubmissionMetadata_WHEN_AppResetIsTriggered_THEN_SubmissionMetadataIsNotNil() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		store.isPrivacyPreservingAnalyticsConsentGiven = true
		store.lastAppReset = nil
		
		// WHEN
		Analytics.collect(.submissionMetadata(.lastAppReset(Date())))
		
		// THEN
		XCTAssertNotNil(store.lastAppReset)
	}
	
	// This test has the target to ensure that no property is added to the PPAnalyticsData and then missed to delete when the function is called.
	func testGIVEN_SomeAnalyticsData_WHEN_DeleteIsCalled_THEN_AnalyticsDataAreDeleted() {
		// GIVEN
		let store = MockTestStore()
		Analytics.setupMock(store: store)
		let exposureRiskMetadata = RiskExposureMetadata(
			riskLevel: .high,
			riskLevelChangedComparedToPreviousSubmission: true,
			dateChangedComparedToPreviousSubmission: false
		)
		
		store.currentENFRiskExposureMetadata = exposureRiskMetadata
		store.previousENFRiskExposureMetadata = exposureRiskMetadata
		store.userMetadata = UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29)
		store.lastSubmittedPPAData = "Some Fake Data"
		store.lastAppReset = Date()
		store.lastSubmissionAnalytics = Date()
		store.clientMetadata = ClientMetadata(etag: "FakeTag")
		store.pcrTestResultMetadata = TestResultMetadata(registrationToken: "FakeToken", testType: .pcr)
		store.pcrKeySubmissionMetadata = KeySubmissionMetadata(
			submitted: true,
			submittedInBackground: false,
			submittedAfterCancel: true,
			submittedAfterSymptomFlow: false,
			lastSubmissionFlowScreen: .submissionFlowScreenUnknown,
			advancedConsentGiven: true,
			hoursSinceTestResult: 0901,
			hoursSinceTestRegistration: 0901,
			daysSinceMostRecentDateAtRiskLevelAtTestRegistration: 0901,
			hoursSinceHighRiskWarningAtTestRegistration: 0901,
			submittedWithTeleTAN: false,
			submittedAfterRapidAntigenTest: false,
			daysSinceMostRecentDateAtCheckinRiskLevelAtTestRegistration: -1,
			hoursSinceCheckinHighRiskWarningAtTestRegistration: -1,
			submittedWithCheckIns: nil
		)
		store.exposureWindowsMetadata = ExposureWindowsMetadata(
			newExposureWindowsQueue: [],
			reportedExposureWindowsQueue: []
		)
		
		// creates a dummy implementation that implements PPAnalyticsData to count the properties to be deleted dynamically.
		let dummyImplementation = TestDummyPPAnalyticsDataImplementation()
			
		let mirror = Mirror(reflecting: dummyImplementation)
		// -1 because currentExposureWindows list should not be emptied
		let countOfPropertiesToDelete = mirror.children.count - 1
		var countOfDeletedProperties = 0
		
		// WHEN
		Analytics.deleteAnalyticsData()
		
		// THEN
		XCTAssertNil(store.currentENFRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.previousENFRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.currentCheckinRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.previousCheckinRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.userMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastSubmittedPPAData)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastAppReset)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastSubmissionAnalytics)
		countOfDeletedProperties += 1
		XCTAssertNil(store.clientMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.pcrTestResultMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.antigenTestResultMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.pcrKeySubmissionMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.antigenKeySubmissionMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.exposureWindowsMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.dateOfConversionToENFHighRisk)
		countOfDeletedProperties += 1
		XCTAssertNil(store.dateOfConversionToCheckinHighRisk)
		countOfDeletedProperties += 1
		
		XCTAssertEqual(countOfPropertiesToDelete, countOfDeletedProperties, "The count must match. Did you perhaps forget to delete a property in Analytics.deleteAnalyticsData()?")
	}
}
