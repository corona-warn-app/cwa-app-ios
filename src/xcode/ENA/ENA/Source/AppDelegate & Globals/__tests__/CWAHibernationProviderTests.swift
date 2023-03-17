//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CWAHibernationProviderTests: CWATestCase {
	
	func testIsHibernationState_HibernationStartDate_beforeSystemDate_true() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		let today = Date()
		let yesterday = today.addingTimeInterval(-86400) // 1 day in seconds
		
		// WHEN
		mockTestStore.hibernationStartDate = yesterday
		
		// THEN
		XCTAssertTrue(sut.isHibernationState)
	}
	
	func testIsHibernationState_HibernationStartDate_afterSystemDate_false() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		let today = Date()
		let tomorrow = today.addingTimeInterval(86400) // 1 day in seconds
		
		// WHEN
		mockTestStore.hibernationStartDate = tomorrow
		
		// THEN
		XCTAssertFalse(sut.isHibernationState)
	}
}
