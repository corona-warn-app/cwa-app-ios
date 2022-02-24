////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SelectValueViewModelTests: CWATestCase {

	func testGIVEN_emptyValues_WHEN_getCount_THEN_IsOne() {
		// GIVEN
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel([], title: "", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		let count = viewModel.numberOfSelectableValues

		// THEN
		XCTAssertEqual(1, count)
	}
	
	func testGIVEN_accessibilityIdentifier_WHEN_getIdentifier_THEN_isCorrect() {
		// GIVEN
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel([], title: "", initialValue: initialValue, accessibilityIdentifier: "fakeIdentifier", selectionCellIconType: .checkmark)

		// WHEN
		let accessibilityIdentifier = viewModel.accessibilityIdentifier

		// THEN
		XCTAssertEqual(accessibilityIdentifier, "fakeIdentifier")
	}

	func testGIVEN_viewModel_WHEN_getTitle_THEN_IsUnchanged() {
		// GIVEN
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel([], title: "⚙️", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		let title = viewModel.title

		// THEN
		XCTAssertEqual("⚙️", title)
	}

	func testGIVEN_viewModel_WHEN_getSelectedIndex_THEN_IsSetupCorrect() {
		// GIVEN
		let selectableValues = [
			SelectableValue(title: "1"),
			SelectableValue(title: "3"),
			SelectableValue(title: "2")
		]
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel(selectableValues, title: "⚙️", preselected: "3", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		let selected = viewModel.selectedTupel

		// THEN
		XCTAssertNil(selected.0)
		XCTAssertEqual(3, selected.1)
	}

	func testGIVEN_viewModel_WHEN_getTwoCellViewModel_THEN_selectionIsTrue() {
		// GIVEN
		let selectableValues = [
			SelectableValue(title: "1"),
			SelectableValue(title: "3"),
			SelectableValue(title: "2")
		]
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel(selectableValues, title: "⚙️", preselected: "3", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		let selectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 3, section: 0))
		let unselectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertEqual("3", selectedCellViewModel.text)
		XCTAssertEqual(UIImage(imageLiteralResourceName: "Icons_Checkmark"), selectedCellViewModel.image)

		XCTAssertEqual("keine Angabe", unselectedCellViewModel.text)
		XCTAssertNil(unselectedCellViewModel.image)
	}


	func testGIVEN_viewModel_WHEN_changeSelectedValue_THEN_selectionIsCorrect() {
		// GIVEN
		let selectableValues = [
			SelectableValue(title: "1"),
			SelectableValue(title: "3"),
			SelectableValue(title: "2")
		]
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel(selectableValues, title: "⚙️", preselected: "3", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 0, section: 0))
		let unselectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 2, section: 0))
		let selectedCellViewModel = viewModel.cellViewModel(for: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertEqual("keine Angabe", selectedCellViewModel.text)
		XCTAssertEqual(UIImage(imageLiteralResourceName: "Icons_Checkmark"), selectedCellViewModel.image)

		XCTAssertEqual("2", unselectedCellViewModel.text)
		XCTAssertNil(unselectedCellViewModel.image)
	}

	func testGIVEN_ViewModel_WHEN_SelectNoValue_THEN_SelectedValueIsNil() {
		// GIVEN
		let selectableValues = [
			SelectableValue(title: "1"),
			SelectableValue(title: "3"),
			SelectableValue(title: "2")
		]
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel(selectableValues, title: "⚙️", preselected: "3", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 0, section: 0))

		// THEN
		XCTAssertNil(viewModel.selectedValue)
	}

	func testGIVEN_ViewModel_WHEN_SelectOutOfBoundsValue_THEN_SelectedValueIsUnchanged() {
		// GIVEN
		let selectableValues = [
			SelectableValue(title: "1"),
			SelectableValue(title: "2"),
			SelectableValue(title: "3")
		]
		let initialValue = SelectableValue(title: AppStrings.DataDonation.ValueSelection.noValue, isEnabled: true)
		let viewModel = SelectValueViewModel(selectableValues, title: "⚙️", preselected: "3", initialValue: initialValue, accessibilityIdentifier: "", selectionCellIconType: .checkmark)

		// WHEN
		viewModel.selectValue(at: IndexPath(row: 1, section: 0))
		viewModel.selectValue(at: IndexPath(row: 5, section: 0))

		// THEN
		XCTAssertEqual(viewModel.selectedValue?.title, "1")
	}

}
