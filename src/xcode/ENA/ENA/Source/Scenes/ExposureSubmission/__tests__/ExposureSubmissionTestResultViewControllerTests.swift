//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionViewControllerTests: XCTestCase {
	
	private var store: Store!
	
	
	override func setUpWithError() throws {
		store = MockTestStore()
	}

	private func createVC(coronaTest: CoronaTest) -> ExposureSubmissionTestResultViewController {
		let store = MockTestStore()
		store.pcrTest = PCRTest.mock(testResult: .positive)

		return ExposureSubmissionTestResultViewController(
			viewModel: ExposureSubmissionTestResultViewModel(
				coronaTestType: .pcr,
				coronaTestService: CoronaTestService(client: ClientMock(), store: store),
				warnOthersReminder: WarnOthersReminder(store: self.store),
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: { },
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { _ in },
				onTestDeleted: { }
			),
			exposureSubmissionService: MockExposureSubmissionService(),
			onDismiss: { _, _ in }
		)
	}

	func testPositiveState() {
		let vc = createVC(coronaTest: CoronaTest.pcr(PCRTest.mock(testResult: .positive)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)

		let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? DynamicTypeTableViewCell
		XCTAssertNotNil(cell)
		XCTAssertEqual(cell?.contentTextLabel.text, AppStrings.ExposureSubmissionPositiveTestResult.noConsentTitle)
	}

}
