////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ErrorReportHistoryViewModelTests: CWATestCase {
	
	func testSectionsOfViewModel() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel(historyItems: mockHistory())
		let tableViewModel = historyViewModel.dynamicTableViewModel
		
		// WHEN
		let numberOfSections = tableViewModel.content.count
		
		// THEN
		XCTAssertEqual(numberOfSections, 2)
	}
	
	func testForNumberOfStaticCells() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel(historyItems: mockHistory())
		let tableViewModel = historyViewModel.dynamicTableViewModel

		// WHEN
		let numberOfCells = tableViewModel.numberOfRows(inSection: 0, for: DynamicTableViewController())

		// THEN
		XCTAssertEqual(numberOfCells, 2)
	}
	
	func testForNumberofDynamicCells() throws {
		// GIVEN
		let numHistoryItems = 42 // because!
		let historyViewModel = ErrorReportHistoryViewModel(historyItems: mockHistory(count: numHistoryItems))
		let tableViewModel = historyViewModel.dynamicTableViewModel

		// WHEN
		let numberOfCells = tableViewModel.numberOfRows(inSection: 1, for: DynamicTableViewController())

		// THEN
		XCTAssertEqual(numberOfCells, historyViewModel.items.count)
		XCTAssertEqual(numberOfCells, numHistoryItems)
	}

	func testReuseIdentifierHistoryCell() throws {
		// GIVEN
		let historyViewModel = ErrorReportHistoryViewModel(historyItems: mockHistory())
		let tableViewModel = historyViewModel.dynamicTableViewModel

		// WHEN
		let cell2 = tableViewModel.section(1).cells[0]

		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, ErrorReportHistoryViewController.CustomCellReuseIdentifiers.historyCell.rawValue)
	}

	// MARK: – Helpers

	private func mockHistory(count: Int = 2) -> [ErrorLogUploadReceipt] {
		var items: [ErrorLogUploadReceipt] = []
		for i in 0..<count {
			items.append(ErrorLogUploadReceipt(id: i.description, timestamp: Date()))
		}
		return items
	}
}
