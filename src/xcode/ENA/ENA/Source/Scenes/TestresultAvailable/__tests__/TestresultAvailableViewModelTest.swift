//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TestresultAvailableViewModelTest: XCTestCase {

	func testGIVEN_ViewModel_WHEN_PrimaryButtonClosureCalled_THEN_ExpectationFulfill() {
		// GIVEN
		let mockStore = MockTestStore()
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell conde excecute")
		expectationNotFulFill.isInverted = true

		let viewModel = TestresultAvailableViewModel(
			mockStore,
			didTapConsentCell: {
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: {
				expectationFulFill.fulfill()
			})

		// WHEN
		viewModel.didTapPrimaryFooterButton()

		// THEN
		waitForExpectations(timeout: .medium)
	}

	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellMatchExpectation() {
		// GIVEN
		let mockStore = MockTestStore()
		let expectationNotFulFill = expectation(description: "consent cell conde excecute")
		expectationNotFulFill.isInverted = true

		let viewModel = TestresultAvailableViewModel(
			mockStore,
			didTapConsentCell: {
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: {
				expectationNotFulFill.fulfill()
			})

		// WHEN
		let dynamicTableViewModel = viewModel.dynamicTableViewModel

		// THEN
		XCTAssertEqual(3, dynamicTableViewModel.numberOfSection)
		XCTAssertEqual(0, dynamicTableViewModel.numberOfRows(section: 0))
		XCTAssertEqual(1, dynamicTableViewModel.numberOfRows(section: 1))
		XCTAssertEqual(2, dynamicTableViewModel.numberOfRows(section: 2))
		waitForExpectations(timeout: .short)
	}

}
