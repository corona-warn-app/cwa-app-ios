//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SRSConsentViewModelTests: XCTestCase {
	
	func testDynamicTableViewModel() {
		let viewModel = SRSConsentViewModel()
		
		let dynamicTableViewModel = viewModel.dynamicTableViewModel
		
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 5)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 4)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 2)
		XCTAssertEqual(dynamicTableViewModel.section(3).cells.count, 5)
		XCTAssertEqual(dynamicTableViewModel.section(4).cells.count, 1)
	}
	
}
