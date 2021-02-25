////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FooterViewModelTests: XCTestCase {

	func testGIVEN_FooterViewModel_THEN_AllValuesSetAsGiven() {
		// GIVEN
		let viewModel = FooterViewModel(
			primaryButtonName: "button 1",
			secondaryButtonName: "button 2"
		)

		// THEN
		XCTAssertEqual(viewModel.primaryButtonName, "button 1")
		XCTAssertEqual(viewModel.secondaryButtonName, "button 2")
		XCTAssertTrue(viewModel.isPrimaryButtonEnabled)
		XCTAssertTrue(viewModel.isSecondaryButtonEnabled)
		XCTAssertFalse(viewModel.isPrimaryButtonHidden)
		XCTAssertFalse(viewModel.isSecondaryButtonHidden)
	}

}
