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

}
