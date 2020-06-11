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
		let vc = createVC()
		_ = vc.view
		let title = "Second Button Test"
		vc.setSecondaryButtonTitle(title: title)
		vc.showSecondaryButton()

		XCTAssert(!vc.secondaryButton.isHidden)
		XCTAssertEqual(vc.secondaryButton.currentTitle, title)
		XCTAssertEqual(vc.secondaryButton.state, UIButton.State.normal)
	}

	func testHideSecondaryButton() {
		let vc = createVC()
		_ = vc.view
		vc.showSecondaryButton()

		XCTAssert(!vc.secondaryButton.isHidden)
		vc.hideSecondaryButton()
		XCTAssert(vc.secondaryButton.isHidden)
	}

	func testSecondaryButtonAction() {
		let vc = createVC()
		_ = vc.view

		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapSecondButtonCallback = { expectation.fulfill() }

		vc.pushViewController(child, animated: false)
		vc.secondaryButton.sendActions(for: .touchUpInside)

		waitForExpectations(timeout: .short)
	}

	func testButtonAction() {
		let vc = createVC()
		_ = vc.view

		let child = MockExposureSubmissionNavigationControllerChild()
		let expectation = self.expectation(description: "Button action executed.")
		child.didTapButtonCallback = { expectation.fulfill() }

		vc.pushViewController(child, animated: false)
		vc.button.sendActions(for: .touchUpInside)

		waitForExpectations(timeout: .short)
	}

	func testExposureSubmissionService() {
		let vc = createVC()
		XCTAssertNotNil(vc.getExposureSubmissionService())
	}

}
