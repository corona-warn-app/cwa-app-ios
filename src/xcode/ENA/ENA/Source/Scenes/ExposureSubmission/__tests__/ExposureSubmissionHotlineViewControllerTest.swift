//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionHotlineViewControllerTest: XCTestCase {

	func testSetupView() {
		let vc = ExposureSubmissionHotlineViewController(onSecondaryButtonTap: {}, dismiss: {})

		_ = vc.view
		XCTAssertNotNil(vc.tableView)
		XCTAssertEqual(vc.tableView.numberOfSections, 2)
		XCTAssertEqual(vc.tableView(vc.tableView, numberOfRowsInSection: 1), 5)
	}

}
