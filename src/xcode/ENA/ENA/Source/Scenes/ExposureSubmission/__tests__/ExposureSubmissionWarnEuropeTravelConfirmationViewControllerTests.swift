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

class ExposureSubmissionWarnEuropeTravelConfirmationViewControllerTests: XCTestCase {

	private lazy var viewController: ExposureSubmissionWarnEuropeTravelConfirmationViewController = {
		// fake handler
		let handler: ExposureSubmissionWarnEuropeTravelConfirmationViewController.PrimaryButtonHandler = { _, completion in
			completion(false)
		}

		return AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnEuropeTravelConfirmationViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnEuropeTravelConfirmationViewController(coder: coder, onPrimaryButtonTap: handler)
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
		XCTAssertEqual(viewController.navigationItem.title, AppStrings.ExposureSubmissionWarnEuropeCountrySelection.title)
		XCTAssertFalse(viewController.navigationItem.hidesBackButton, "Expected back button")
		XCTAssertEqual(viewController.tableView.numberOfSections, 1)
		XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 3)
	}

	func test_HastTravelConfirmationSelection() throws {
		// find a travel confirmation cell
		let cell = try XCTUnwrap(viewController.tableView.visibleCells.compactMap({ $0 as? DynamicTableViewOptionGroupCell }).first)
		XCTAssertNil(cell.selection, "Expected no preselection")

		XCTAssertEqual(cell.reuseIdentifier, ExposureSubmissionWarnEuropeTravelConfirmationViewController.CustomCellReuseIdentifiers.optionGroupCell.rawValue)
		_ = try XCTUnwrap(cell.subviews.compactMap({ $0 as? OptionGroupView }).first)
	}

}
