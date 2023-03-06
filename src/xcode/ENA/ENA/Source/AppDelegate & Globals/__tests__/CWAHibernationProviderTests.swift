//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CWAHibernationProviderTests: CWATestCase {
	
	func testIsHibernationState_Store_HibernationComparisonDate_before_false() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		
		// WHEN
		var beforeHibernationStartDateComponents = DateComponents()
		beforeHibernationStartDateComponents.year = 2023
		beforeHibernationStartDateComponents.month = 4
		beforeHibernationStartDateComponents.day = 30
		beforeHibernationStartDateComponents.hour = 23
		beforeHibernationStartDateComponents.minute = 59
		beforeHibernationStartDateComponents.second = 59
		beforeHibernationStartDateComponents.timeZone = .utcTimeZone
		
		guard let hibernationComparisonDate = Calendar.current.date(from: beforeHibernationStartDateComponents) else {
			return XCTFail("Expect the hibernation comparison date from the corresponding date components.")
		}
		mockTestStore.hibernationComparisonDate = hibernationComparisonDate
		
		// THEN
		XCTAssertFalse(sut.isHibernationState)
	}

    func testIsHibernationState_Store_HibernationComparisonDate_after_true() throws {
		// GIVEN
		let mockTestStore = MockTestStore()
		let sut = CWAHibernationProvider(customStore: mockTestStore)
		
		// WHEN
		var afterHibernationStartDateComponents = DateComponents()
		afterHibernationStartDateComponents.year = 2023
		afterHibernationStartDateComponents.month = 5
		afterHibernationStartDateComponents.day = 1
		afterHibernationStartDateComponents.hour = 0
		afterHibernationStartDateComponents.minute = 0
		afterHibernationStartDateComponents.second = 0
		afterHibernationStartDateComponents.timeZone = .utcTimeZone

		guard let hibernationComparisonDate = Calendar.current.date(from: afterHibernationStartDateComponents) else {
			return XCTFail("Expect the hibernation comparison date from the corresponding date components.")
		}
		mockTestStore.hibernationComparisonDate = hibernationComparisonDate
		
		// THEN
		XCTAssertTrue(sut.isHibernationState)
    }
}
