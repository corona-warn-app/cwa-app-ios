//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionSuccessViewControllerTest: XCTestCase {

	func testSetupView() {
		let vc = ExposureSubmissionSuccessViewController(dismiss: { })

		_ = vc.view
		XCTAssertEqual(vc.navigationItem.title, AppStrings.ExposureSubmissionSuccess.title)
		XCTAssertTrue(vc.navigationItem.hidesBackButton)
		XCTAssertEqual(vc.tableView.numberOfSections, 1)
		XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 9)
	}

}
