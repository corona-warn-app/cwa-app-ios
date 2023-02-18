//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CWAHibernationProviderTests: CWATestCase {

    func testIsHibernationState_DeveloperMenuSetting_true() throws {
		// GIVEN
		let sut = CWAHibernationProvider.shared
		
		// WHEN
        // to.do Dev Setting true
		// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-14812
		
		// THEN
		XCTAssertTrue(sut.isHibernationState)
    }
	
	func testIsHibernationState_DeveloperMenuSetting_false() throws {
		// to.do Dev Setting false
		// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-14812
	}
}
