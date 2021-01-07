//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewControllerNumberOfRowsAndSectionsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		sut = DynamicTableViewController()
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
