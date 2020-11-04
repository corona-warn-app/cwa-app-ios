import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionViewControllerTests: XCTestCase {

	private func createVC(testResult: TestResult) -> ExposureSubmissionTestResultViewController {
		ExposureSubmissionTestResultViewController(
			viewModel: ExposureSubmissionTestResultViewModel(
				testResult: testResult,
				exposureSubmissionService: MockExposureSubmissionService(),
				onContinueWithSymptomsFlowButtonTap: { _ in },
				onContinueWithoutSymptomsFlowButtonTap: { _ in },
				onTestDeleted: { }
			)
		)
	}

	func testPositiveState() {
		let vc = createVC(testResult: .positive)
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)

		let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? DynamicTypeTableViewCell
		XCTAssertNotNil(cell)
		XCTAssertEqual(cell?.textLabel?.text, AppStrings.ExposureSubmissionResult.procedure)
	}

}
