//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class ExposureSubmissionNavigationControllerTest: XCTestCase {

	private func createVC() -> ExposureSubmissionNavigationController {
		// rootVC needs to be a ENANavigationControllerWithFooterChild to support buttons.
		let rootVC = ExposureSubmissionHotlineViewController()

		return ExposureSubmissionNavigationController(
			dismissClosure: {},
			rootViewController: rootVC
		)
	}

	func testSetupSecondaryButton() {
		let vc = createVC()
		_ = vc.view

		let rootVC = vc.topViewController
		let navItem = rootVC?.navigationItem as? ENANavigationFooterItem

		let title = "Second Button Test"

		navItem?.secondaryButtonTitle = title
		navItem?.isSecondaryButtonHidden = false

		XCTAssertFalse(vc.footerView.secondaryButton.isHidden)
		XCTAssertEqual(vc.footerView.secondaryButton.currentTitle, title)
		XCTAssertEqual(vc.footerView.secondaryButton.state, UIButton.State.normal)
	}

	func testHideSecondaryButton() {
		let vc = createVC()
		_ = vc.view

		let rootVC = vc.topViewController
		let navItem = rootVC?.navigationItem as? ENANavigationFooterItem

		navItem?.isSecondaryButtonHidden = false
		XCTAssertFalse(vc.footerView.secondaryButton.isHidden)

		navItem?.isSecondaryButtonHidden = true
		XCTAssertLessThan(vc.footerView.secondaryButton.alpha, 0.01)
	}

	func testSecondaryButtonAction() {
		let vc = createVC()
		_ = vc.view
		
		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapSecondButtonCallback = { expectation.fulfill() }
		
		vc.pushViewController(child, animated: false)
		vc.footerView.secondaryButton.sendActions(for: .touchUpInside)
		
		waitForExpectations(timeout: .short)
	}

	func testButtonAction() {
		let vc = createVC()
		_ = vc.view

		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapButtonCallback = { expectation.fulfill() }

		vc.pushViewController(child, animated: false)
		vc.footerView.primaryButton.sendActions(for: .touchUpInside)

		waitForExpectations(timeout: .short)
	}
	
}
