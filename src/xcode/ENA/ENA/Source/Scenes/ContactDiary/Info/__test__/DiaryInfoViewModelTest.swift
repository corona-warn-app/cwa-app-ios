////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA


class DiaryInfoViewModelTest: XCTestCase {

	/// test if the information screen has 3 sections (image, legal and disclaimer)
	func testGIVEN_ViewModel_WHEN_GetNumberOfSections_THEN_CountMatchExpectations() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let numberOfSection = viewModel.dynamicTableViewModel.numberOfSection

		// THEN
		XCTAssertEqual(numberOfSection, 3)
	}

	// check if image section (0) contains right image
	func testGIVEN_ViewModeln_WHEN_Header_THEN_ImageMatch() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let dynamicHeader = viewModel.dynamicTableViewModel.content[0].header

		// THEN
		switch dynamicHeader {
		case .image(let image, _, _, _, _):
			XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Illu_ContactDiary-Information"))
		default:
			XCTFail("Found wrong header image")
		}
	}

	/// test if number of cells in information section (0) is correct
	func testGIVEN_ViewModel_WHEN_GetNumberOfCellsInInformationSection_THEN_CountMatchExpectations() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let numberOfCells = viewModel.dynamicTableViewModel.numberOfRows(section: 0)

		// THEN
		XCTAssertEqual(numberOfCells, 14)
	}

	/// test if number of cells in legal section (1) is correct
	func testGIVEN_ViewModel_WHEN_GetNumberOfCellsInLegalSection_THEN_CountMatchExpectations() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let numberOfCells = viewModel.dynamicTableViewModel.numberOfRows(section: 1)

		// THEN
		XCTAssertEqual(numberOfCells, 1)
	}

	/// test if number of cells in disclaimer section (1) is correct
	func testGIVEN_ViewModel_WHEN_GetNumberOfCellsInDisclaimerSection_THEN_CountMatchExpectations() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let numberOfCells = viewModel.dynamicTableViewModel.numberOfRows(section: 2)

		// THEN
		XCTAssertEqual(numberOfCells, 1)
	}

	/// test if action on disclaimer cell will trigger view model closure
	func testGIVEN_ViewModel_WHEN_GetDisclaimerCell_THEN_ActionWillTrigger() {
		// GIVEN
		let disclaimerHitExpectation = expectation(description: "trigger closure in view model")
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {
			disclaimerHitExpectation.fulfill()
		})

		// WHEN
		let cell = viewModel.dynamicTableViewModel.cell(at: IndexPath(row: 0, section: 2))
		switch cell.action {
		case .execute(let block):
			block(UIViewController(), nil)
		default:
			XCTFail("wrong cell action found")
		}

		// THEN
		waitForExpectations(timeout: .medium)
	}

}
