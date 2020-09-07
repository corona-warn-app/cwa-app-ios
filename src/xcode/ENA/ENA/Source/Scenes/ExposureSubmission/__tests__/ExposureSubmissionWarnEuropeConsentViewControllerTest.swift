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

class ExposureSubmissionWarnEuropeConsentViewControllerTest: XCTestCase {

	private var viewController: ExposureSubmissionWarnEuropeConsentViewController = {
		// fake handler
		let handler: ExposureSubmissionWarnEuropeConsentViewController.PrimaryButtonHandler = { _, completion in
			completion(false)
		}

		return AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnEuropeConsentViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnEuropeConsentViewController(coder: coder, onPrimaryButtonTap: handler)
		}
	}()
	private var rootWindow: UIWindow!

	override func setUp() {
		rootWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
		rootWindow.rootViewController = viewController
		rootWindow.makeKeyAndVisible()
		viewController.tableView.reloadData()
	}

	func testViewLoading() {
		XCTAssertEqual(viewController.navigationItem.title, AppStrings.ExposureSubmissionWarnEuropeConsent.title)
		XCTAssertFalse(viewController.navigationItem.hidesBackButton, "Expected back button")
		XCTAssertEqual(viewController.tableView.numberOfSections, 3)
		XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
		XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 1), 1)
		XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 2), 1)
	}

	func test_ConsentSwitchCell() throws {
		let cell = try XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? DynamicTableViewIconCell)
		let accessoryView = try XCTUnwrap(cell.accessoryView as? UISwitch)
		XCTAssertEqual(accessoryView.isOn, false, "Assumed consent initially denied")
	}
}
