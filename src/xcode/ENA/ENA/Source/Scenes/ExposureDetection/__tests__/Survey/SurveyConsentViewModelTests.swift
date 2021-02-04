////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SurveyConsentViewModelTests: XCTestCase {

	func testDynamicTableViewModel() {
		let viewModel = SurveyConsentViewModel()

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 4)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 1)
	}
}
