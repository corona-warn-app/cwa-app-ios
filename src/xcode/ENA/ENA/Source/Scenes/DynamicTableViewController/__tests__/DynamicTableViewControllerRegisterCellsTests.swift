//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewControllerRegisterCellsTests: XCTestCase {
	
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

// MARK: - Register Cells
extension DynamicTableViewControllerRegisterCellsTests {
	
	func testViewDidLoad_registersDynamicTypeCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.dynamicType(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.dynamicTypeLabel.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell)
	}
	
	func testViewDidLoad_registersSpaceCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.space(height: 1)])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.space.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewSpaceCell)
	}
	
	func testViewDidLoad_registersIconCell() {
		let dynamicCell = DynamicCell.icon(nil, text: .string("Foo"), tintColor: .green, action: .none)
		let sections = [DynamicSection.section(cells: [dynamicCell])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)

		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.icon.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewIconCell)
	}

	func testViewDidLoad_registersTextViewCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.dynamicType(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)

		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.dynamicTypeTextView.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewTextViewCell)
	}
}
