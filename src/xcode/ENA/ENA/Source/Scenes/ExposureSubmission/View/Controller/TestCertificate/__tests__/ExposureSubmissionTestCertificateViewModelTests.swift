////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionTestCertificateViewModelTests: XCTestCase {

	func testGIVEN_PCRTest_WHEN_getDynamicTableViewModel_THEN_NumberOfCellsShouldMatch() {
		// GIVEN
		let viewModel = ExposureSubmissionTestCertificateViewModel(
			testType: .pcr,
			presentDisclaimer: {}
		)

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 7)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 1)
		XCTAssertFalse(viewModel.isPrimaryButtonEnabled)
	}

	func testGIVEN_AntigenTest_WHEN_getDynamicTableViewModel_THEN_NumberOfCellsShoudMatch() {
		// GIVEN
		let viewModel = ExposureSubmissionTestCertificateViewModel(
			testType: .antigen,
			presentDisclaimer: {}
		)

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 3)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 5)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 1), 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 2), 1)
		XCTAssertTrue(viewModel.isPrimaryButtonEnabled)
	}


	func testGIVEN_PCRTest_WHEN_getBirthdayDatePickerCell_THEN_NumberOfCellsShouldMatch() throws {
		// GIVEN
		let indexPath = IndexPath(row: 1, section: 0)
		let viewModel = ExposureSubmissionTestCertificateViewModel(
			testType: .pcr,
			presentDisclaimer: {}
		)

		// WHEN
		let cell = viewModel.dynamicTableViewModel.cell(at: indexPath)
		XCTAssertEqual(cell.cellReuseIdentifier.rawValue, BirthdayDatePickerCell.reuseIdentifier)
	}

}
