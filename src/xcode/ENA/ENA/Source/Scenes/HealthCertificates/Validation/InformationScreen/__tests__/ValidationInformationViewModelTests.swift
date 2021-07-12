////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ValidationInformationViewModelTests: XCTestCase {

	func testGIVEN_ViewModel_WHET_getDynamicTableViewModel_THEN_IsInitializedCorrect() {
		// GIVEN
		let viewModel = ValidationInformationViewModel()

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 3)
	}

}
