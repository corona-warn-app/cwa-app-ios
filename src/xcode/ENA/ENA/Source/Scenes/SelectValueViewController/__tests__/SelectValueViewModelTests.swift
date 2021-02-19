////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SelectValueViewModelTests: XCTestCase {

	func testGIVEN_emptyValues_WHEN_getCount_THEN_IsOne() {
		// GIVEN
		let viewModel = SelectValueViewModel([], title: "", accessibilityIdentifier: "")

		// WHEN
		let count = viewModel.numberOfSelectableValues

		// THEN
		XCTAssertEqual(1, count)
	}
	
	func testGIVEN_accessibilityIdentifier_WHEN_getIdentifier_THEN_isCorrect() {
		// GIVEN
		let viewModel = SelectValueViewModel([], title: "", accessibilityIdentifier: "fakeIdentifier")

		// WHEN
		let accessibilityIdentifier = viewModel.accessibilityIdentifier

		// THEN
		XCTAssertEqual(accessibilityIdentifier, "fakeIdentifier")
	}

	func testGIVEN_viewModel_WHEN_getTitle_THEN_IsUnchanged() {
		// GIVEN
		let viewModel = SelectValueViewModel([], title: "⚙️", accessibilityIdentifier: "")

		// WHEN
		let title = viewModel.title

		// THEN
		XCTAssertEqual("⚙️", title)
	}

	func testGIVEN_viewModel_WHEN_getSelectedIndex_THEN_IsSetupCorrect() {
		// GIVEN
		let viewModel = SelectValueViewModel(["1", "3", "2"], title: "⚙️", preselected: "3", accessibilityIdentifier: "")

		// WHEN
		let selected = viewModel.selectedTupel

		// THEN
		XCTAssertNil(selected.0)
		XCTAssertEqual(3, selected.1)
	}

	func testGIVEN_viewModel_WHEN_getTwoCellViewModel_THEN_selectionIsTrue() {
		// GIVEN
		let viewModel = SelectValueViewModel(["1", "3", "2"], title: "⚙️", preselected: "3", accessibilityIdentifier: "")

		// WHEN
		let selectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 3, section: 0))
		let unselectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertEqual("3", selectedCellViewModel.text)
		XCTAssertEqual(UIImage(imageLiteralResourceName: "Icons_Checkmark"), selectedCellViewModel.checkmarkImage)

		XCTAssertEqual("keine Angabe", unselectedCellViewModel.text)
		XCTAssertNil(unselectedCellViewModel.checkmarkImage)
	}


	func testGIVEN_viewModel_WHEN_changeSelectedValue_THEN_selectionIsCorrect() {
		// GIVEN
		let viewModel = SelectValueViewModel(["1", "3", "2"], title: "⚙️", preselected: "3", accessibilityIdentifier: "")

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 0, section: 0))
		let unselectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 2, section: 0))
		let selectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertEqual("keine Angabe", selectedCellViewModel.text)
		XCTAssertEqual(UIImage(imageLiteralResourceName: "Icons_Checkmark"), selectedCellViewModel.checkmarkImage)

		XCTAssertEqual("2", unselectedCellViewModel.text)
		XCTAssertNil(unselectedCellViewModel.checkmarkImage)
	}

	func testGIVEN_ViewModel_WHEN_SelectNoValue_THEN_SelectedValueIsNil() {
		// GIVEN
		let viewModel = SelectValueViewModel(["1", "3", "2"], title: "⚙️", preselected: "3", accessibilityIdentifier: "")

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertNil(viewModel.selectedValue)
	}

	func testGIVEN_ViewModel_WHEN_SelectOutOfBoundsValue_THEN_SelectedValueIsUnchanged() {
		// GIVEN
		let viewModel = SelectValueViewModel(["1", "3", "2"], title: "⚙️", preselected: "3", accessibilityIdentifier: "")

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 1, section: 0))
		viewModel.selectValue(at: IndexPath(row: 5, section: 0))

		// THEN
		XCTAssertEqual(viewModel.selectedValue, "1")
	}

}
