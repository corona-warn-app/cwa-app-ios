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
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(coder: coder, coordinator: MockExposureSubmissionCoordinator(), exposureSubmissionService: self.service)
		}
	}

	func testSuccessfulSubmit() {
		let vc = createVC()
		_ = vc.view

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
		XCTAssert(alert.actions[1].title == AppStrings.Common.errorAlertActionMoreInfo)
		XCTAssert(alert.message == AppStrings.Common.enError11Description)
	}

	func testShowENErrorAlertUnsupported() {
		let vc = createVC()
		_ = vc.view

		let alert = vc.createENAlert(.unsupported)
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == AppStrings.Common.errorAlertActionMoreInfo)
		XCTAssert(alert.message == AppStrings.Common.enError5Description)
	}

	func testShowENErrorAlertRateLimited() {
		let vc = createVC()
		_ = vc.view

		let alert = vc.createENAlert(.rateLimited)
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == AppStrings.Common.errorAlertActionMoreInfo)
		XCTAssert(alert.message == AppStrings.Common.enError13Description)
	}

	func testGetURLInternal() {
		let url = ExposureSubmissionError.internal.faqURL
		XCTAssert(url?.absoluteString == AppStrings.Links.appFaqENError11)
	}

	func testGetURLUnsupported() {
		let url = ExposureSubmissionError.unsupported.faqURL
		XCTAssert(url?.absoluteString == AppStrings.Links.appFaqENError5)
	}

	func testGetURLRateLimited() {
		let url = ExposureSubmissionError.rateLimited.faqURL
		XCTAssert(url?.absoluteString == AppStrings.Links.appFaqENError13)
	}

	func testCellsOnScreen() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssert(cells.count == 4)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssert(id.rawValue == "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssert(id.rawValue == "labelCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssert(id.rawValue == "roundedCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssert(id.rawValue == "roundedCell")

	}
}
