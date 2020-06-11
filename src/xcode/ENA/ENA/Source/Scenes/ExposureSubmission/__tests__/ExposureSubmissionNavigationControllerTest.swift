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

class ExposureSubmissionNavigationControllerTest: XCTestCase {

	private func createVC() -> ExposureSubmissionNavigationController {
		return AppStoryboard.exposureSubmission.initiateInitial { coder in
			ExposureSubmissionNavigationController(
				coder: coder,
				exposureSubmissionService: MockExposureSubmissionService(),
				homeViewController: nil,
				testResult: nil
			)
		}
	}

	func testSetupSecondaryButton() {
		let viewCtrl = createVC()
		_ = viewCtrl.view
		let title = "Second Button Test"
		viewCtrl.setSecondaryButtonTitle(title: title)
		viewCtrl.showSecondaryButton()

		XCTAssert(!viewCtrl.secondaryButton.isHidden)
		XCTAssertEqual(viewCtrl.secondaryButton.currentTitle, title)
		XCTAssertEqual(viewCtrl.secondaryButton.state, UIButton.State.normal)
	}

	func testHideSecondaryButton() {
		let viewCtrl = createVC()
		_ = viewCtrl.view
		viewCtrl.showSecondaryButton()

		XCTAssert(!viewCtrl.secondaryButton.isHidden)
		viewCtrl.hideSecondaryButton()
		XCTAssert(viewCtrl.secondaryButton.isHidden)
	}

	func testSecondaryButtonAction() {
		let viewCtrl = createVC()
		_ = viewCtrl.view

		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapSecondButtonCallback = { expectation.fulfill() }

		viewCtrl.pushViewController(child, animated: false)
		viewCtrl.secondaryButton.sendActions(for: .touchUpInside)

		waitForExpectations(timeout: .short)
	}

	func testButtonAction() {
		let viewCtrl = createVC()
		_ = viewCtrl.view

		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapButtonCallback = { expectation.fulfill() }

		viewCtrl.pushViewController(child, animated: false)
		viewCtrl.button.sendActions(for: .touchUpInside)

		waitForExpectations(timeout: .short)
	}

	func testExposureSubmissionService() {
		let viewCtrl = createVC()
		XCTAssertNotNil(viewCtrl.getExposureSubmissionService())
	}

}
