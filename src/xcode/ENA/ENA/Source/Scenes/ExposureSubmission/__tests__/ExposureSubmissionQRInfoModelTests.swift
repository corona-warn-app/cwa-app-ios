//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionQRInfoModelTests: XCTestCase {

	func testDynamicTableViewModel() {
		let viewModel = ExposureSubmissionQRInfoViewModel(supportedCountries: [])

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 7)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(1).cells.count, 3)
		XCTAssertEqual(dynamicTableViewModel.section(2).cells.count, 2)
		XCTAssertEqual(dynamicTableViewModel.section(3).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(4).cells.count, 1)
		XCTAssertEqual(dynamicTableViewModel.section(5).cells.count, 6)
		XCTAssertEqual(dynamicTableViewModel.section(6).cells.count, 1)
	}

}
