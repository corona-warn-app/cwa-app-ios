//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

class ExposureSubmissionViewControllerTests: CWATestCase {

	private func createVC(coronaTest: UserCoronaTest) -> ExposureSubmissionTestResultViewController {
		let coronaTestService = MockCoronaTestService()

		switch coronaTest.type {
		case .pcr:
			coronaTestService.pcrTest.value = coronaTest.pcrTest as? UserPCRTest
		case .antigen:
			coronaTestService.antigenTest.value = coronaTest.antigenTest as? UserAntigenTest
		}

		return ExposureSubmissionTestResultViewController(
			viewModel: ExposureSubmissionTestResultViewModel(
				coronaTestType: coronaTest.type,
				coronaTestService: coronaTestService,
				onSubmissionConsentCellTap: { _ in },
				onContinueWithSymptomsFlowButtonTap: { },
				onContinueWarnOthersButtonTap: { _ in },
				onChangeToPositiveTestResult: { },
				onTestDeleted: { },
				onTestCertificateCellTap: { _, _ in }
			),
			exposureSubmissionService: MockExposureSubmissionService(),
			onDismiss: { _, _ in }
		)
	}

	func testPositivePCRState() {
		let vc = createVC(coronaTest: .pcr(.mock(testResult: .positive)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)

		let cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? DynamicTypeTableViewCell
		XCTAssertNotNil(cell)
		XCTAssertEqual(cell?.contentTextLabel.text, AppStrings.ExposureSubmissionPositiveTestResult.noConsentTitle)
	}

	func testNegativePCRState() {
		let vc = createVC(coronaTest: .pcr(.mock(testResult: .negative)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? ExposureSubmissionTestResultHeaderView
		XCTAssertNotNil(header)
	}
	
	func testNegativeAntigenState() {
		let vc = createVC(coronaTest: .antigen(.mock(testResult: .negative)))
		_ = vc.view
		XCTAssertEqual(vc.dynamicTableViewModel.numberOfSection, 1)

		let header = vc.tableView(vc.tableView, viewForHeaderInSection: 0) as? AntigenExposureSubmissionNegativeTestResultHeaderView
		XCTAssertNotNil(header)
	}
}
