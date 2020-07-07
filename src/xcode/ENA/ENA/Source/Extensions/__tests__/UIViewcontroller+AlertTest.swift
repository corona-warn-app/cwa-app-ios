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

class UIViewcontroller_AlertTest: XCTestCase {

	var mockVC = UIViewController()

	override func setUp() {
		super.setUp()

		if let vc = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController() {
			mockVC = vc
		}

		UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController = mockVC
	}

	func testAlert() {
		let expectation = self.expectation(description: "myExpectation")
		expectation.expectedFulfillmentCount = 3

		mockVC.alertError(message: AppStrings.ExposureNotificationError.apiMisuse, title: AppStrings.ExposureNotificationError.generalErrorTitle, optInActions: [UIAlertAction(), UIAlertAction()], completion: {
			if let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
				let presentedController = keyWindow.rootViewController?.presentedViewController
				XCTAssertTrue(presentedController is UIAlertController)
				expectation.fulfill()
				if let alertController = presentedController as? UIAlertController {
					XCTAssertTrue(alertController.actions.count == 3)
					expectation.fulfill()
					XCTAssert(alertController.title == AppStrings.ExposureSubmission.generalErrorTitle)
					XCTAssert(alertController.message == AppStrings.ExposureNotificationError.apiMisuse)
					expectation.fulfill()
				}
			}
			else {
				XCTestError(.timeoutWhileWaiting)
			}
		})
		waitForExpectations(timeout: 2)
	}

	func testAlertSimple() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(!alert.actions.isEmpty)
	}

	func testAlertSingleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(message: "Error Message")

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(alert.actions.count == 1)
	}

	func testAlertDoubleAction() throws {
		let vc = UIViewController()
		let alert = vc.setupErrorAlert(
			message: "Error Message",
			secondaryActionTitle: "Retry Title"
		)

		XCTAssert(alert.title == AppStrings.ExposureSubmission.generalErrorTitle)
		XCTAssert(alert.message == "Error Message")
		XCTAssert(alert.actions.count == 2)
		XCTAssert(alert.actions[1].title == "Retry Title")
	}

}
