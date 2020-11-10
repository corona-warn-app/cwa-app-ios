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

class DynamicCellTests: XCTestCase {
	// A `DynamicTableViewController` is required to test the `DynamicCell` configurations,
	// as `CellConfigurator` require an instance of `DynamicTableViewController`
	var dynamicVC: DynamicTableViewController!
	var window: UIWindow!

	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerRowsTests.self)
		let storyboardFake = UIStoryboard(name: "DynamicTableViewControllerFake", bundle: testBundle)
		// The force unwrap it used here because when the type doesn't match, a
		// crash immedeately informs about a problem in the test.
		guard let viewController = storyboardFake.instantiateViewController(identifier: "DynamicTableViewController") as? DynamicTableViewController
			else {
				XCTAssert(false, "Unable to instantiate DynamicTableViewController from DynamicTableViewControllerFake.storyboard")
				return
		}
		dynamicVC = viewController

		// trigger viewDidLoad
		dynamicVC.loadViewIfNeeded()

		window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.makeKeyAndVisible()
	}

	override func tearDownWithError() throws {
		dynamicVC = nil
		window = nil
	}
}

extension DynamicCellTests {
	// MARK: - Dynamic Type Cell Tests

	func testMakeDynamicCell_TextCell_DefaultIsLabelStyle() {
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo")])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = dynamicVC

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		XCTAssert(cell is DynamicTableViewTextCell)
	}

	func testMakeDynamicCell_UseTextViewCellStyle() {
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo", cellStyle: .textView([]))])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = dynamicVC

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		XCTAssert(cell is DynamicTableViewTextViewCell)
	}

	func testMakeDynamicCell_UseTextViewCellStyle_WithDataDetectors() throws {
		let expectedDetectors = UIDataDetectorTypes.all
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo", cellStyle: .textView(expectedDetectors))])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = dynamicVC

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		let textViewCell = try XCTUnwrap(cell as? DynamicTableViewTextViewCell)
		let textView = try textViewCell.getTextView()
		XCTAssertEqual(textView.dataDetectorTypes, expectedDetectors)
	}

	// MARK: - Body Dynamic Cell Tests

	func testMakeDynamicCell_Body_DefaultIsLabelStyle() {
		let section = DynamicSection.section(cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = dynamicVC

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		XCTAssert(cell is DynamicTableViewTextCell)
	}
}

// MARK: - Helpers

private extension DynamicTableViewTextViewCell {
	func getTextView() throws -> UITextView {
		return try XCTUnwrap(contentView.subviews.first(where: { $0 is UITextView }) as? UITextView)
	}
}
