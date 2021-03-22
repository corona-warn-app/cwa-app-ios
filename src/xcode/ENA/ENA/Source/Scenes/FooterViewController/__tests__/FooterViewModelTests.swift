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
		XCTAssertNil(viewModel.primaryButtonColor)
		XCTAssertNil(viewModel.secondaryButtonColor)
		XCTAssertEqual(viewModel.height, 140.0)
	}

	func testGIVEN_FooterViewModel_WHEN_UnhidePrimaryButton_THEN_HightChanged() {
		// GIVEN
		let viewModel = FooterViewModel(
			primaryButtonName: "test",
			secondaryButtonName: "test2",
			isPrimaryButtonHidden: true,
			isSecondaryButtonHidden: true
		)

		// WHEN
		let initialHeight = viewModel.height

		viewModel.update(to: .primary)
		let primaryOnlyVisible = viewModel.height

		viewModel.update(to: .both)
		let bothVisible = viewModel.height

		viewModel.update(to: .none)
		let bothHidden = viewModel.height

		// THEN
		XCTAssertEqual(initialHeight, bothHidden)
		XCTAssertEqual(primaryOnlyVisible, viewModel.buttonHeight + viewModel.spacer + viewModel.topBottomInset * 2)
		XCTAssertEqual(bothVisible, viewModel.buttonHeight * 2 + viewModel.spacer + viewModel.topBottomInset * 2)
	}

}
