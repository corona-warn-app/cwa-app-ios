////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DataDonationDetailsViewModelTests: XCTestCase {

	let model = DataDonationDetailsViewModel()
	
	func testForOneSection() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let numberOfSections = tableViewModel.content.count
		// THEN
		XCTAssertEqual(numberOfSections, 1)
	}

	func testForNumberOfCells() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let numberOfCells = tableViewModel.section(0).cells.count
		// THEN
		XCTAssertEqual(numberOfCells, 36)
	}

	func testReuseIdentifierRoundedCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell2 = tableViewModel.section(0).cells[2]
		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, "roundedCell")
	}

	// cells 8-11, 13-16, 18-22, 24-30, 32-34
	func testReuseIdentifierBulletPointCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		let indexSet = [8, 9, 10, 11, 13, 14, 15, 16, 18, 19, 20, 21, 22, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34]
		// WHEN
		for i in indexSet {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "bulletPointCell")
		}
	}

	// cells 0, 4, 6, 12, 17, 23, 31, 35
	func testReuseIdentifierLabelCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		let indexSet = [0, 4, 6, 12, 17, 23, 31, 35]
		// WHEN
		for i in indexSet {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "labelCell")
		}
	}
	
	func testReuseIdentifierSpaceCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		let indexSet = [1, 3, 5, 7]
		// WHEN
		for i in indexSet {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "spaceCell")
		}
	}

}
