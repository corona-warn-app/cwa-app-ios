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
	

	// test deleted analytics data
	
	// test submitter is triggered
}

