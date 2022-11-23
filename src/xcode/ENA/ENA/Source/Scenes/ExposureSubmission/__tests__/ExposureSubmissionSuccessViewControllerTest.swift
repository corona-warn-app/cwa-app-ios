//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionSuccessViewControllerTest: CWATestCase {

	func testPCR() {
		let vc = ExposureSubmissionSuccessViewController(submissionTestType: .registeredTest(.pcr), dismiss: { })

		_ = vc.view
		XCTAssertEqual(vc.navigationItem.title, AppStrings.ExposureSubmissionSuccess.title)
		XCTAssertTrue(vc.navigationItem.hidesBackButton)
		XCTAssertEqual(vc.tableView.numberOfSections, 1)
		XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 11)
	}

	func testAntigen() {
		let vc = ExposureSubmissionSuccessViewController(submissionTestType: .registeredTest(.antigen), dismiss: { })

		_ = vc.view
		XCTAssertEqual(vc.navigationItem.title, AppStrings.ExposureSubmissionSuccess.title)
		XCTAssertTrue(vc.navigationItem.hidesBackButton)
		XCTAssertEqual(vc.tableView.numberOfSections, 1)
		XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 11)
	}
	
	func testSRS() {
		let vc = ExposureSubmissionSuccessViewController(submissionTestType: .srs(.srsSelfTest), dismiss: { })

		_ = vc.view
		XCTAssertEqual(vc.navigationItem.title, AppStrings.ExposureSubmissionSuccess.title)
		XCTAssertTrue(vc.navigationItem.hidesBackButton)
		XCTAssertEqual(vc.tableView.numberOfSections, 1)
		XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 11)
	}

}
