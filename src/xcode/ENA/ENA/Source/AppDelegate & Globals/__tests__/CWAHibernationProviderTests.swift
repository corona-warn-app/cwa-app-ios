//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CWAHibernationProviderTests: CWATestCase {
	
	func testIsHibernationState_Store_HibernationComparingDate_before_false() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		
		// WHEN
		var beforeHibernationStartDateComponents = DateComponents()
		beforeHibernationStartDateComponents.year = 2023
		beforeHibernationStartDateComponents.month = 5
		beforeHibernationStartDateComponents.day = 31
		beforeHibernationStartDateComponents.hour = 23
		beforeHibernationStartDateComponents.minute = 59
		beforeHibernationStartDateComponents.second = 59
		beforeHibernationStartDateComponents.timeZone = .utcTimeZone
		
		mockTestStore.hibernationComparingDate = Calendar.current.date(from: beforeHibernationStartDateComponents)!
		
		// THEN
		XCTAssertFalse(sut.isHibernationState)
	}

    func testIsHibernationState_Store_HibernationComparingDate_after_true() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		
		// WHEN
		var afterHibernationStartDateComponents = DateComponents()
		afterHibernationStartDateComponents.year = 2023
		afterHibernationStartDateComponents.month = 6
		afterHibernationStartDateComponents.day = 1
		afterHibernationStartDateComponents.hour = 0
		afterHibernationStartDateComponents.minute = 0
		afterHibernationStartDateComponents.second = 0
		afterHibernationStartDateComponents.timeZone = .utcTimeZone

		mockTestStore.hibernationComparingDate = Calendar.current.date(from: afterHibernationStartDateComponents)!
		
		// THEN
		XCTAssertTrue(sut.isHibernationState)
    }
}
