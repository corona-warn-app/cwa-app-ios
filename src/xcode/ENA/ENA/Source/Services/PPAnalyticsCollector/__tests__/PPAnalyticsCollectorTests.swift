////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPAnalyticsCollectorTests: XCTestCase {
	
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
		
		store.currentRiskExposureMetadata = exposureRiskMetadata
		store.previousRiskExposureMetadata = exposureRiskMetadata
		store.userMetadata = UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29)
		store.lastSubmittedPPAData = "Some Fake Data"
		store.lastAppReset = Date()
		store.lastSubmissionAnalytics = Date()
		store.clientMetadata = ClientMetadata(etag: "FakeTag")
		store.testResultMetadata = TestResultMetadata(registrationToken: "FakeToken")
		store.keySubmissionMetadata = KeySubmissionMetadata(
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
			submittedWithTeleTAN: true
		)
		store.exposureWindowsMetadata = ExposureWindowsMetadata(
			newExposureWindowsQueue: [],
			reportedExposureWindowsQueue: []
		)
		
		// creates a dummy implementation that implements PPAnalyticsData to count the properties to be deleted dynamically.
		let dummyImplementation = TestDummyPPAnalyticsDataImplementation()
			
		let mirror = Mirror(reflecting: dummyImplementation)
		let countOfPropertiesToDelete = mirror.children.count
		var countOfDeletedProperties = 0
		
		// WHEN
		Analytics.deleteAnalyticsData()
		
		// THEN
		XCTAssertNil(store.currentRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.previousRiskExposureMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.userMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastSubmittedPPAData)
		countOfDeletedProperties += 1
		XCTAssertFalse(store.submittedWithQR)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastAppReset)
		countOfDeletedProperties += 1
		XCTAssertNil(store.lastSubmissionAnalytics)
		countOfDeletedProperties += 1
		XCTAssertNil(store.clientMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.testResultMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.keySubmissionMetadata)
		countOfDeletedProperties += 1
		XCTAssertNil(store.exposureWindowsMetadata)
		countOfDeletedProperties += 1
		
		XCTAssertEqual(countOfPropertiesToDelete, countOfDeletedProperties, "The count must match. Did you perhaps forget to delete a property in Analytics.deleteAnalyticsData()?")

	}

}
