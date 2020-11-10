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

class DynamicTableViewControllerNumberOfRowsAndSectionsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerNumberOfRowsAndSectionsTests.self)
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

// MARK: - Number of rows and sections
extension DynamicTableViewControllerNumberOfRowsAndSectionsTests {
	func testNumberOfSections_returnsValueFromViewModel_withOneSection() {
		// setup view model
		let sections = [
			DynamicSection.section(cells: [.headline(text: "Foo",
													 accessibilityIdentifier: "Foo")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfSections_returnsValueFromViewModel_withThreeSections() {
		// setup view model
		let sections: [DynamicSection] = [
			.section(cells: [.headline(text: "Foo",
									   accessibilityIdentifier: "Foo")]),
			.section(cells: [.headline(text: "Bar",
									   accessibilityIdentifier: "Bar")]),
			.section(cells: [.headline(text: "Baz",
									   accessibilityIdentifier: "Baz")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withOneCell() {
		// setup view model
		let cells = [
			DynamicCell.headline(
				text: "Foo",
				accessibilityIdentifier: "Foo"
			)
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withThreeCells() {
		// setup view model
		let cells: [DynamicCell] = [
			.headline(text: "Foo",
					  accessibilityIdentifier: "Foo"),
			.headline(text: "Bar",
					  accessibilityIdentifier: "Bar"),
			.headline(text: "Baz",
					  accessibilityIdentifier: "Baz")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsOne_forHiddenSection() {
		// setup view model
		let cells: [DynamicCell] = [
			.headline(text: "Foo",
					  accessibilityIdentifier: "Foo"),
			.headline(text: "Bar",
					  accessibilityIdentifier: "Bar"),
			.headline(text: "Baz",
					  accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// hidden sections have only one cell
		XCTAssertEqual(numberOfCells, 1)
	}
}
