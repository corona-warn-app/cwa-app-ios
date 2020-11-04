import XCTest
@testable import ENA

class ExposureSubmissionHotlineViewControllerTest: XCTestCase {

	func testSetupView() {
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionHotlineViewController.self) { coder -> UIViewController? in
			ExposureSubmissionHotlineViewController(coder: coder, coordinator: MockExposureSubmissionCoordinator())
		}
		_ = vc.view
		XCTAssertNotNil(vc.tableView)
		XCTAssertEqual(vc.tableView.numberOfSections, 2)
		XCTAssertEqual(vc.tableView(vc.tableView, numberOfRowsInSection: 1), 5)
	}

}
