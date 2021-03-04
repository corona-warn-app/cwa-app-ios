////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ErrorReportHistoryViewModelTests: XCTestCase {
	
	func testSectionsOfViewModel() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel()
		let tableViewModel = historyViewModel.dynamicTableViewModel
		
		// WHEN
		let numberOfSections = tableViewModel.content.count
		
		// THEN
		XCTAssertEqual(numberOfSections, 2)
	}
	
	func testForNumberOfStaticCells() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel()
		let tableViewModel = historyViewModel.dynamicTableViewModel

		// WHEN
		let numberOfCells = tableViewModel.numberOfRows(inSection: 0, for: DynamicTableViewController())

		// THEN
		XCTAssertEqual(numberOfCells, 2)
	}
	
	func testReuseIdentifierHistoryCell() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel()
		let tableViewModel = historyViewModel.dynamicTableViewModel

		// WHEN
		let cell2 = tableViewModel.section(1).cells[0]

		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell.rawValue)
	}
}
