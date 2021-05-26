////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestOverwriteNoticeViewModelTests: CWATestCase {

	func testGIVEN_ViewModelWithPcr_THEN_IsInitializedCorrect() {
		// GIVEN
		let viewModel = TestOverwriteNoticeViewModel(.pcr)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.ExposureSubmission.OverwriteNotice.title)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 2)
	}

	func testGIVEN_ViewModelWithAntigen_THEN_IsInitializedCorrect() {
		// GIVEN
		let viewModel = TestOverwriteNoticeViewModel(.antigen)

		// THEN
		XCTAssertEqual(viewModel.title, AppStrings.ExposureSubmission.OverwriteNotice.title)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(viewModel.dynamicTableViewModel.numberOfRows(section: 0), 2)
	}


}
