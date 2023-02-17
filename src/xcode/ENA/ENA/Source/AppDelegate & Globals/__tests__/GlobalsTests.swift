//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class GlobalsTests: CWATestCase {

    func testIsHibernationState_DeveloperMenuSetting_true() throws {
        // to.do Dev Setting true
		// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-14812
		
		XCTAssertTrue(isHibernationState)
    }
	
	func testIsHibernationState_DeveloperMenuSetting_false() throws {
		// to.do Dev Setting false
		// https://jira-ibs.wbs.net.sap/browse/EXPOSUREAPP-14812
	}
}
