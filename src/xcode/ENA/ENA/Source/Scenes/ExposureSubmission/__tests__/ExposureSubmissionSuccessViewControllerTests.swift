import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionSuccessViewControllerTests: XCTestCase {

	private func createVC() -> ExposureSubmissionSuccessViewController {
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionSuccessViewController.self) { coder -> UIViewController? in
			ExposureSubmissionSuccessViewController(coder: coder, coordinator: MockExposureSubmissionCoordinator())
		}
	}

	func testViewLoading() {
		let vc = createVC()
		_ = vc.view

		XCTAssertEqual(vc.navigationItem.title, AppStrings.ExposureSubmissionSuccess.title)
		XCTAssertTrue(vc.navigationItem.hidesBackButton)
		XCTAssertEqual(vc.tableView.numberOfSections, 1)
		XCTAssertEqual(vc.tableView.numberOfRows(inSection: 0), 9)
	}
}
