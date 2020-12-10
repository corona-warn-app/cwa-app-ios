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
		case .image(let image, _, _, _):
			XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Illu_ContactDiary-Information"))
		default:
			XCTFail("Found wrong header image")
		}
	}

	/// test if number of cells in information section (0) is correct
	func testGIVEN_ViewModel_WHEN_GetNumberOfCellsInSectionZero_THEN_CountMatchExpectations() {
		// GIVEN
		let viewModel = DiaryInfoViewModel(presentDisclaimer: {})

		// WHEN
		let numberOfCells = viewModel.dynamicTableViewModel.numberOfRows(section: 0)

		// THEN
		XCTAssertEqual(numberOfCells, 8)
	}
}
