//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class FamilyMemberConsentViewModelTests: CWATestCase {

	func testGIVEN_ViewModel_WHEN_dataSource_THEN_CountsMatch() {
		// GIVEN
		let viewModel = FamilyMemberConsentViewModel("Test", presentDisclaimer: {})

		// WHEN
		let dataSource = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(viewModel.name?.value, "Test")
		XCTAssertEqual(dataSource.numberOfSection, 3)
		XCTAssertEqual(dataSource.numberOfRows(section: 0),	5)
		XCTAssertEqual(dataSource.numberOfRows(section: 1),	1)
		XCTAssertEqual(dataSource.numberOfRows(section: 2),	1)
	}

	func testGIVEN_ViewModel_WHEN_DisclaimerCellExecute_THEN_presentDisclaimer() {
		// GIVEN
		let disclaimerExpectation = expectation(description: "Disclaimer tapped")
		let viewModel = FamilyMemberConsentViewModel(
			"Test",
			presentDisclaimer: {
				disclaimerExpectation.fulfill()
			}
		)

		// WHEN
		let dataSource = viewModel.dynamicTableViewModel
		let disclaimerCell = dataSource.cell(at: IndexPath(row: 0, section: 2))
		if case let .execute(block) = disclaimerCell.action {
			block(UIViewController(), nil)
		}

		// THEN

		waitForExpectations(timeout: .short)
	}

}
