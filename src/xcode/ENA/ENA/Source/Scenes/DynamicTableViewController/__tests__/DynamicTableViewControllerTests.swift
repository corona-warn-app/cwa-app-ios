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

// MARK: - Register Cells
extension DynamicTableViewControllerTests {
	
	func testViewDidLoad_registersBoldCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.bold(text: "Foo")])]
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
		let sections = [DynamicSection.section(cells: [.semibold(text: "Foo")])]
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
		let sections = [DynamicSection.section(cells: [.regular(text: "Foo")])]
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
		let sections = [DynamicSection.section(cells: [.bigBold(text: "Foo")])]
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
			DynamicSection.section(cells: [.bold(text: "Foo")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfSections_returnsValueFromViewModel_withThreeSections() {
		// setup view model
		let sections: [DynamicSection] = [
			.section(cells: [.bold(text: "Foo")]),
			.section(cells: [.bold(text: "Bar")]),
			.section(cells: [.bold(text: "Baz")])
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
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withThreeCells() {
		// setup view model
		let cells: [DynamicCell] = [
			.bold(text: "Foo"),
			.bold(text: "Bar"),
			.bold(text: "Baz")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsOne_forHiddenSection() {
		// setup view model
		let cells: [DynamicCell] = [
			.bold(text: "Foo"),
			.bold(text: "Bar"),
			.bold(text: "Baz")
		]
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// hidden sections have only one cell
		XCTAssertEqual(numberOfCells, 1)
	}
}

// MARK: - Header
extension DynamicTableViewControllerTests {
	func testTitleForHeaderInSection_whenHeaderIsText_returnsHeaderText() {
		// set up view model
		let expectedHeaderTitle = "Foo"
		let section = DynamicSection.section(header: .text(expectedHeaderTitle),
																				 cells: [.bold(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertEqual(headerTitle, expectedHeaderTitle)
	}
	
	func testTitleForHeaderInSection_whenHeaderIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(header: .text("Foo"),
																				 isHidden: { _ in return true },
																				 cells: [.bold(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertNil(headerTitle)
	}
	
	func testTitleForHeaderInSection_whenHeaderIsNotText_returnsNil() {

		let dynamicHeader: [DynamicHeader] = [
			.none,
			.blank,
			.space(height: 1),
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicHeader.forEach { header in
			let section = DynamicSection.section(header: header,
																					 cells: [.bold(text: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header title from data source
			let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
			
			XCTAssertNil(headerTitle)
		}
	}
}

// MARK: - Footer
extension DynamicTableViewControllerTests {
	func testTitleForFooterInSection_whenFooterIsText_returnsFooterText() {
		// set up view model
		let expectedFooterTitle = "Foo"
		let section = DynamicSection.section(footer: .text(expectedFooterTitle), cells: [.bold(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertEqual(footerTitle, expectedFooterTitle)
	}
	
	func testTitleForFooterInSection_whenFooterIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(footer: .text("Foo"),
																				 isHidden: { _ in return true },
																				 cells: [.bold(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertNil(footerTitle)
	}
	
	func testTitleForFooterInSection_whenFooterIsNotText_returnsNil() {

		let dynamicFooter: [DynamicFooter] = [
			.none,
			.blank,
			.space(height: 1),
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicFooter.forEach { footer in
			let section = DynamicSection.section(footer: footer,
																					 cells: [.bold(text: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header title from data source
			let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
			
			XCTAssertNil(footerTitle)
		}
	}
}
