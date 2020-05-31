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

class DynamicTableViewControllerTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerTests.self)
		let storyboardFake = UIStoryboard(name: "DynamicTableViewControllerFake", bundle: testBundle)
		// The force unwrap it used here because when the type doesn't match, a
		// crash immedeately informs about a problem in the test.
		sut = (storyboardFake.instantiateViewController(identifier: "DynamicTableViewController") as! DynamicTableViewController)
		// trigger viewDidLoad
		sut.loadViewIfNeeded()
	}
	
	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - Register Cells
extension DynamicTableViewControllerTests {
	
	func testViewDidLoad_registersBoldCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [DynamicCell.bold(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicTableViewController.CellReuseIdentifier.bold.rawValue
		let cell = sut.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
																								 for: IndexPath(row: 0, section: 0))
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell.Bold)
	}
	
	func testViewDidLoad_registersSemiboldCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [DynamicCell.semibold(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicTableViewController.CellReuseIdentifier.semibold.rawValue
		let cell = sut.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
																								 for: IndexPath(row: 0, section: 0))
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell.Semibold)
	}
	
	func testViewDidLoad_registersRegularCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [DynamicCell.regular(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicTableViewController.CellReuseIdentifier.regular.rawValue
		let cell = sut.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
																								 for: IndexPath(row: 0, section: 0))
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell.Regular)
	}
	
	func testViewDidLoad_registersBigBoldCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [DynamicCell.bigBold(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicTableViewController.CellReuseIdentifier.bigBold.rawValue
		let cell = sut.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
																								 for: IndexPath(row: 0, section: 0))
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell.BigBold)
	}
	
	func testViewDidLoad_registersIconCell() {
		let dynamicCell = DynamicCell.icon(action: .none, .init(text: "Foo", image: nil, backgroundColor: .red, tintColor: .green))
		let sections = [DynamicSection.section(cells: [dynamicCell])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)

		// dequeue cell
		let reuseIdentifier = DynamicTableViewController.CellReuseIdentifier.icon.rawValue
		let cell = sut.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
																								 for: IndexPath(row: 0, section: 0))
		// assert type
		XCTAssertTrue(cell is DynamicTableViewIconCell)
	}
}

// MARK: - Number of rows and sections
extension DynamicTableViewControllerTests {
	func testNumberOfSections_returnsValueFromViewModel_withOneSection() {
		// setup view model
		let sections = [
			DynamicSection.section(cells: [DynamicCell.bold(text: "Foo")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfSections_returnsValueFromViewModel_withThreeSections() {
		// setup view model
		let sections = [
			DynamicSection.section(cells: [DynamicCell.bold(text: "Foo")]),
			DynamicSection.section(cells: [DynamicCell.bold(text: "Bar")]),
			DynamicSection.section(cells: [DynamicCell.bold(text: "Baz")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withOneCell() {
		// setup view model
		let cells = [
			DynamicCell.bold(text: "Foo")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([DynamicSection.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withThreeCells() {
		// setup view model
		let cells = [
			DynamicCell.bold(text: "Foo"),
			DynamicCell.bold(text: "Bar"),
			DynamicCell.bold(text: "Baz")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([DynamicSection.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
}
