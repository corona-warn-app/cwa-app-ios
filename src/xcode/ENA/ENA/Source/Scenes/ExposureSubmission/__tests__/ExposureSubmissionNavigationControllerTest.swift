//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
@testable import ENA

final class ExposureSubmissionNavigationControllerTest: XCTestCase {

	private func createVC() -> ExposureSubmissionNavigationController {
		return AppStoryboard.exposureSubmission.initiateInitial { coder in
			ExposureSubmissionNavigationController(
				coder: coder,
				exposureSubmissionService: MockExposureSubmissionService(),
				submissionDelegate: nil,
				testResult: nil
			)
		}
	}

	func testSetupSecondaryButton() {
		let vc = createVC()
		_ = vc.view

		let rootVC = vc.topViewController
		let navItem = rootVC?.navigationItem as? ENANavigationFooterItem

		let title = "Second Button Test"

		navItem?.secondaryButtonTitle = title
		navItem?.isSecondaryButtonHidden = false

		XCTAssert(!vc.footerView.secondaryButton.isHidden)
		XCTAssertEqual(vc.footerView.secondaryButton.currentTitle, title)
		XCTAssertEqual(vc.footerView.secondaryButton.state, UIButton.State.normal)
	}

	func testHideSecondaryButton() {
		let vc = createVC()
		_ = vc.view

		let rootVC = vc.topViewController
		let navItem = rootVC?.navigationItem as? ENANavigationFooterItem

		navItem?.isSecondaryButtonHidden = false
		XCTAssert(!vc.footerView.secondaryButton.isHidden)

		navItem?.isSecondaryButtonHidden = true
		XCTAssert(vc.footerView.secondaryButton.alpha < 0.01)
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

	func testExposureSubmissionService() {
		XCTAssertNotNil(createVC().exposureSubmissionService)
	}
}
