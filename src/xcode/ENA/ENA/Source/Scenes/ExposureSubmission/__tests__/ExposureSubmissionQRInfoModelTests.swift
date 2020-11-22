//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionQRInfoModelTests: XCTestCase {

	func testDynamicTableVIewModel() {
		let viewModel = ExposureSubmissionQRInfoViewModel()

		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.section(0).cells.count, 4)
	}

}
