////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ErrorReportHistoryViewModelTests: XCTestCase {

	let model = ErrorReportHistoryViewModel()
	
	func testSectionsOfViewModel() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		
		// WHEN
		let numberOfSections = tableViewModel.content.count
		
		// THEN
		XCTAssertEqual(numberOfSections, 2)
	}
	
	func testForNumberOfStaticCells() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel

		// WHEN
		let numberOfCells = tableViewModel.section(0).cells.count

		// THEN
		XCTAssertEqual(numberOfCells, 2)
	}
	
	func testReuseIdentifierHistoryCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel

		// WHEN
		let cell2 = tableViewModel.section(1).cells[0]

		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell.rawValue)
	}
}
