////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPAnalyticsCollectorTests: XCTestCase {
	
	func testGIVEN_NotSetupAnalytics_WHEN_SomethingIsLogged_THEN_NothingIsLogged() {
		// GIVEN
		let store = MockTestStore(withAnalytics: false)
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.log(.userData(.complete(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.setupMock(store: store)
		Analytics.log(.userData(.complete(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		XCTAssertEqual(store.userMetadata?.ageGroup, .ageBelow29)
	}
	
	func testGIVEN_UserConsentNotGiven_WHEN_SomethingIsLogged_THEN_LoggingIsNotAllowed() {
		// GIVEN
		let store = MockTestStore()
		store.isPrivacyPreservingAnalyticsConsentGiven = false
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.log(.userData(.complete(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertNil(store.userMetadata?.ageGroup)
	}
	
	func testGIVEN_UserConsentGiven_WHEN_SomethingIsLogged_THEN_LoggingIsAllowed() {
		// GIVEN
		let store = MockTestStore()
		
		// WHEN
		XCTAssertNil(store.userMetadata?.ageGroup)
		Analytics.log(.userData(.complete(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		
		// THEN
		XCTAssertEqual(store.userMetadata?.ageGroup, .ageBelow29)
	}
	
	func testGIVEN_SomeAnalyticsData_WHEN_DeleteIsCalled_THEN_AnalyticsDataAreDeleted() {
		// GIVEN
		let store = MockTestStore()
		Analytics.log(.userData(.complete(UserMetadata(federalState: .hessen, administrativeUnit: 91, ageGroup: .ageBelow29))))
		Analytics.log(.clientMetadata(.setClientMetaData))
		
		// WHEN
		Analytics.deleteAnalyticsData()
		
		// THEN
		XCTAssertNil(store.currentRiskExposureMetadata)
		XCTAssertNil(store.previousRiskExposureMetadata)
		XCTAssertNil(store.userMetadata)
		XCTAssertNil(store.lastSubmittedPPAData)
		XCTAssertNil(store.lastAppReset)
		XCTAssertNil(store.lastSubmissionAnalytics)
		XCTAssertNil(store.clientMetadata)
		XCTAssertNil(store.testResultMetadata)
		XCTAssertNil(store.keySubmissionMetadata)
		XCTAssertNil(store.exposureWindowsMetadata)
		
	}
}
