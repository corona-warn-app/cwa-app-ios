//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

class DynamicTableViewControllerRowsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
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
		sut = viewController
		// trigger viewDidLoad
		sut.loadViewIfNeeded()
	}
	
	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: Rows
extension DynamicTableViewControllerRowsTests {
	func testHeightForRow_returnsAutomaticDimension() {
		let section = DynamicSection.section(cells: [.body(text: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForRow_whenSectionIsHidden_returnsLeastNonzeroMagnitude() {
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: [.body(text: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testCellForRowAt_configuresCell() {
		let expectedText = "Foo"
		let section = DynamicSection.section(cells: [.body(text: expectedText)])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set up window and set root view controller because otherwise cellForRow
		// returns nil.
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.rootViewController = sut
		window.makeKeyAndVisible()

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		XCTAssertEqual(cell?.textLabel?.text, expectedText)
	}
}
