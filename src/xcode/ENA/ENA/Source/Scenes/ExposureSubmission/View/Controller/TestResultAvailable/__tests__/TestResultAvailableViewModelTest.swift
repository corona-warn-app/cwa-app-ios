//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class TestResultAvailableViewModelTest: CWATestCase {
	
	func testGIVEN_ViewModel_WHEN_PrimaryButtonClosureCalled_THEN_ExpectationFulfill() {
		// GIVEN
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true

		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(testResult: .positive)
		
		let viewModel = TestResultAvailableViewModel(
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSubmissionConsentCellTap: { _ in
				expectationNotFulFill.fulfill()
			},
			onPrimaryButtonTap: { _ in
				expectationFulFill.fulfill()
			},
			onDismiss: {}
		)
		
		// WHEN
		viewModel.onPrimaryButtonTap({ _ in })
		
		// THEN
		waitForExpectations(timeout: .medium)
	}
	
	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_SectionsAndCellMatchExpectation() {
		// GIVEN
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		var bindings: Set<AnyCancellable> = []

		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(testResult: .positive)

		let viewModel = TestResultAvailableViewModel(
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSubmissionConsentCellTap: { _ in
				expectationNotFulFill.fulfill()
			},
			onPrimaryButtonTap: { _ in
				expectationNotFulFill.fulfill()
			},
			onDismiss: {}
		)
		
		// WHEN
		var resultDynamicTableViewModel: DynamicTableViewModel?
		
		viewModel.$dynamicTableViewModel.sink { dynamicTableViewModel in
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
		let expectationFulFill = expectation(description: "primary button code execute")
		let expectationNotFulFill = expectation(description: "consent cell code excecute")
		expectationNotFulFill.isInverted = true
		var bindings: Set<AnyCancellable> = []

		let client = ClientMock()
		let appConfiguration = CachedAppConfigurationMock()
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(testResult: .positive)

		let viewModel = TestResultAvailableViewModel(
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
				client: client,
				store: store,
				eventStore: MockEventStore(),
				diaryStore: MockDiaryStore(),
				appConfiguration: appConfiguration,
				healthCertificateService: HealthCertificateService(
					store: store,
					client: client,
					appConfiguration: appConfiguration
				)
			),
			onSubmissionConsentCellTap: { _ in
				expectationFulFill.fulfill()
			},
			onPrimaryButtonTap: { _ in
				expectationNotFulFill.fulfill()
			},
			onDismiss: {}
		)
		
		var resultDynamicTableViewModel: DynamicTableViewModel?
		let waitForCombineExpectation = expectation(description: "dynamic tableview mode did load")
		viewModel.$dynamicTableViewModel.sink { dynamicTableViewModel in
			resultDynamicTableViewModel = dynamicTableViewModel
			waitForCombineExpectation.fulfill()
		}.store(in: &bindings)
	
		wait(for: [waitForCombineExpectation], timeout: .medium)
		let iconCell = resultDynamicTableViewModel?.cell(at: IndexPath(row: 0, section: 1))
		
		// WHEN
		switch iconCell?.action {
		case .execute(block: let block):
			block( UIViewController(), nil )
		default:
			XCTFail("unknown action type")
		}
		
		// THEN
		wait(for: [expectationFulFill, expectationNotFulFill], timeout: .medium)
	}
}
