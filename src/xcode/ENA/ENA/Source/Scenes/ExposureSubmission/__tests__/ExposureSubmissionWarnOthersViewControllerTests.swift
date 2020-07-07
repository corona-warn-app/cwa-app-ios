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

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionWarnOthersViewControllerTests: XCTestCase {

	var service: MockExposureSubmissionService!

	override func setUp() {
		super.setUp()
		service = MockExposureSubmissionService()
	}

	private func createVC() -> ExposureSubmissionWarnOthersViewController {
		return AppStoryboard.exposureSubmission.initiate(
			viewControllerType: ExposureSubmissionWarnOthersViewController.self
		)
	}

	func testSuccessfulSubmit() {
		let vc = createVC()
		_ = vc.view
		vc.exposureSubmissionService = service

		let expectSubmitExposure = self.expectation(description: "Call submitExposure")
		service.submitExposureCallback = {  completion in

			expectSubmitExposure.fulfill()
			completion(nil)
		}

		// Trigger submission process.
		vc.startSubmitProcess()
		waitForExpectations(timeout: .short)
	}

	func testShowENErrorAlertInternal() {
		let vc = createVC()
		_ = vc.view

		let alert = vc.createENAlert(.internal)
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == AppStrings.ExposureSubmissionError.moreInfo)
		XCTAssert(alert.message == AppStrings.ExposureSubmissionError.internal)
	}

	func testShowENErrorAlertUnsupported() {
		let vc = createVC()
		_ = vc.view

		let alert = vc.createENAlert(.unsupported)
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == AppStrings.ExposureSubmissionError.moreInfo)
		XCTAssert(alert.message == AppStrings.ExposureSubmissionError.unsupported)
	}

	func testShowENErrorAlertRateLimited() {
		let vc = createVC()
		_ = vc.view

		let alert = vc.createENAlert(.rateLimited)
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == AppStrings.ExposureSubmissionError.moreInfo)
		XCTAssert(alert.message == AppStrings.ExposureSubmissionError.rateLimited)
	}

	func testGetURLInternal() {
		let vc = createVC()

		let url = vc.getURL(for: .internal)
		XCTAssert(url?.absoluteString == AppStrings.ExposureSubmissionError.moreInfoURLEN11)
	}

	func testGetURLUnsupported() {
		let vc = createVC()

		let url = vc.getURL(for: .unsupported)
		XCTAssert(url?.absoluteString == AppStrings.ExposureSubmissionError.moreInfoURLEN5)
	}

	func testGetURLRateLimited() {
		let vc = createVC()

		let url = vc.getURL(for: .rateLimited)
		XCTAssert(url?.absoluteString == AppStrings.ExposureSubmissionError.moreInfoURLEN13)
	}

}
