//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class HygieneRulesInfoViewModelTests: XCTestCase {
	
	func test_dynamicTableViewModel() {
		let dynamicTableViewModel = HygieneRulesInfoViewModel().dynamicTableViewModel
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 2)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 6)
	}
}
