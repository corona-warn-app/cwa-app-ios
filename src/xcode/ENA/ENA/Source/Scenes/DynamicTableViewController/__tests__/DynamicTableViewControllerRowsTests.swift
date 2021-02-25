//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewControllerRowsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	var window: UIWindow!
	
	override func setUpWithError() throws {
		sut = DynamicTableViewController()
		
		// trigger viewDidLoad
		sut.loadViewIfNeeded()
		
		window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 1000))
		window.makeKeyAndVisible()
		
		window.rootViewController = sut

	}
	
	override func tearDownWithError() throws {
		sut = nil
		window = nil
	}
}

// MARK: Rows
extension DynamicTableViewControllerRowsTests {
	func testHeightForRow_returnsAutomaticDimension() {
		let section = DynamicSection.section(cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForRow_whenSectionIsHidden_returnsLeastNonzeroMagnitude() {
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testCellForRowAt_configuresCell() {
		let expectedText = "Foo"
		let section = DynamicSection.section(cells: [.body(text: expectedText, accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath) as? DynamicTypeTableViewCell
		
		XCTAssertEqual(cell?.contentTextLabel.text, expectedText)
	}
	
	func testCellForRowAt_whenSectionIsHidden_returnsIsPlainUITableViewCell() {
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		XCTAssertTrue(type(of: unwrappedCell) == UITableViewCell.self, "Got \(type(of: unwrappedCell)), expected \(UITableViewCell.self)")
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsTopSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let topSeparator = unwrappedCell.viewWithTag(100_001)
		let topSeparatorIsSubview = topSeparator?.isDescendant(of: unwrappedCell) ?? false
		XCTAssertTrue(topSeparatorIsSubview)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_NotAddsTopSeparatorToSecondCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let indexPath = IndexPath(row: 1, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let topSeparator = unwrappedCell.contentView.viewWithTag(100_001)
		XCTAssertNil(topSeparator)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsBottomSeparatorToLastCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		sut.tableView.reloadData()
		
		let rowOfLastCell = cells.count - 1
		let indexPath = IndexPath(row: rowOfLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let bottomSeparator = unwrappedCell.viewWithTag(100_002)
		let isSubview = bottomSeparator?.isDescendant(of: unwrappedCell) ?? false
		XCTAssertTrue(isSubview)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_notAddsBottomSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let bottomSeparator = unwrappedCell.contentView.viewWithTag(100_002)
		XCTAssertNil(bottomSeparator)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsInsetSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.viewWithTag(100_003)
		let isSubview = insetSeparator?.isDescendant(of: unwrappedCell) ?? false
		XCTAssertTrue(isSubview)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsInsetSeparatorToIntermediateCells() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let rowOfSecondToLastCell = cells.count - 2
		let indexPath = IndexPath(row: rowOfSecondToLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.viewWithTag(100_003)
		let isSubview = insetSeparator?.isDescendant(of: unwrappedCell) ?? false
		XCTAssertTrue(isSubview)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_notAddsInsetSeparatorToLastCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: .all, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		sut.tableView.reloadData() // Force a reload that new ViewModel gets used
		
		let rowOfLastCell = cells.count - 1
		let indexPath = IndexPath(row: rowOfLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.contentView.viewWithTag(100_003)
		XCTAssertNil(insetSeparator)
	}
}
