//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionViewControllerTests: CWATestCase {
	
	private var store: Store!
	
	
	override func setUpWithError() throws {
		try super.setUpWithError()
		store = MockTestStore()
	}

	private func createVC(coronaTest: CoronaTest) -> ExposureSubmissionTestResultViewController {
		let store = MockTestStore()
		
		switch coronaTest.type {
		case .pcr:
			store.pcrTest = coronaTest.pcrTest
		case .antigen:
			store.antigenTest = coronaTest.antigenTest
		}

		return ExposureSubmissionTestResultViewController(
			viewModel: ExposureSubmissionTestResultViewModel(
				coronaTestType: coronaTest.type,
				coronaTestService: CoronaTestService(
					client: ClientMock(),
					store: store,
					appConfiguration: CachedAppConfigurationMock()
				),
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: { },
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { },
				onTestDeleted: { }
			),
			exposureSubmissionService: MockExposureSubmissionService(),
			onDismiss: { _, _ in }
		)
	}

	func testPositivePCRState() {
		let vc = createVC(coronaTest: CoronaTest.pcr(PCRTest.mock(testResult: .positive)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)

		let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? DynamicTypeTableViewCell
		XCTAssertNotNil(cell)
		XCTAssertEqual(cell?.contentTextLabel.text, AppStrings.ExposureSubmissionPositiveTestResult.noConsentTitle)
	}

	func testNegativePCRState() {
		let vc = createVC(coronaTest: CoronaTest.pcr(PCRTest.mock(testResult: .negative)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)
	}
	
	func testNegativeAntigenState() {
		let vc = createVC(coronaTest: CoronaTest.antigen(AntigenTest.mock(testResult: .negative)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? AntigenExposureSubmissionNegativeTestResultHeaderView
		XCTAssertNotNil(header)
	}
}
