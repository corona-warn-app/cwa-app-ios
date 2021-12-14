//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ContagionInfoViewModelTests: XCTestCase {
	
	func test_dynamicTableViewModel() {
		let dynamicTableViewModel = ContagionInfoViewModel().dynamicTableViewModel
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 4)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 6)
		XCTAssertEqual(dynamicTableViewModel.section(3).cells.count, 2)
	}
}
