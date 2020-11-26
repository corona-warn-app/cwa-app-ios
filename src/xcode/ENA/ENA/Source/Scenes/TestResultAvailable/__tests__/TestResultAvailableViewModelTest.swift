//
// 🦠 Corona-Warn-App
//

import XCTest
import Combine
@testable import ENA

class TestResultAvailableViewModelTest: XCTestCase {
	
	func testGIVEN_ViewModel_WHEN_PrimaryButtonClosureCalled_THEN_ExpectationFulfill() {
		// GIVEN
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		
		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: MockExposureSubmissionService(),
			didTapConsentCell: {
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: {
				expectationFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		// WHEN
		viewModel.didTapPrimaryFooterButton()
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellMatchExpectation() {
		// GIVEN
		let exposureSubmissionService = MockExposureSubmissionService()
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		var bindings: Set<AnyCancellable> = []

		let viewModel = TestResultAvailableViewModel(
			exposureSubmissionService: exposureSubmissionService,
			didTapConsentCell: {
				expectationNotFulFill.fulfill()
			},
			didTapPrimaryFooterButton: {
				expectationNotFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		// WHEN
		var resultDynamicTableViewModel: DynamicTableViewModel?
		
		viewModel.dynamicTableviewModelPublisher.sink { dynamicTableViewModel in
			guard let dynamicTableViewModel = dynamicTableViewModel else {
				XCTFail("failed to get dynamicTableViewModel")
				return
			}
			resultDynamicTableViewModel = dynamicTableViewModel
		}.store(in: &bindings)

		// THEN
		waitForExpectations(timeout: .short)
		XCTAssertEqual(3, resultDynamicTableViewModel?.numberOfSection)
		XCTAssertEqual(0, resultDynamicTableViewModel?.numberOfRows(section: 0))
		XCTAssertEqual(1, resultDynamicTableViewModel?.numberOfRows(section: 1))
		XCTAssertEqual(2, resultDynamicTableViewModel?.numberOfRows(section: 2))
	}
	
	func testGIVEN_ViewModel_WHEN_GetIconCellActionTigger_THEN_ExpectationFulfill() {
		// GIVEN
		let mockStore = MockTestStore()
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell conde excecute")
		expectationNotFulFill.isInverted = true
		
		let viewModel = TestResultAvailableViewModel(
			mockStore,
			didTapConsentCell: {
				expectationFulFill.fulfill()
			},
			didTapPrimaryFooterButton: {
				expectationNotFulFill.fulfill()
			},
			presentDismissAlert: {}
		)
		
		let iconCell = viewModel.dynamicTableViewModel.cell(at: IndexPath(row: 0, section: 1))
		
		// WHEN
		switch iconCell.action {
		case .execute(block: let block):
			block( UIViewController(), nil )
		default:
			XCTFail("unknown action type")
		}
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
}
