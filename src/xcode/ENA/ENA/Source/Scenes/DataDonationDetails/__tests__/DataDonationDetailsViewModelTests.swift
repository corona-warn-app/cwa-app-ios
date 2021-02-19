////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DataDonationDetailsViewModelTests: XCTestCase {

	let totalNumberOfCells = 35
	let indexOfBulletPointCells = [7, 8, 9, 10, 12, 13, 14, 15, 17, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33]
	let indexOfSpaceCells = [1, 3, 5]
	let indexOfLabelCells = [0, 4, 6, 11, 16, 22, 30, 34]
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
		XCTAssertEqual(numberOfCells, totalNumberOfCells)
	}

	func testReuseIdentifierRoundedCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell2 = tableViewModel.section(0).cells[2]
		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, "roundedCell")
	}

	func testReuseIdentifierBulletPointCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		for i in indexOfBulletPointCells {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "bulletPointCell")
		}
	}

	func testReuseIdentifierLabelCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		for i in indexOfLabelCells {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "labelCell")
		}
	}
	
	func testReuseIdentifierSpaceCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		for i in indexOfSpaceCells {
			let cell = tableViewModel.section(0).cells[i]
			// THEN
			XCTAssertEqual(cell.cellReuseIdentifier.rawValue, "spaceCell")
		}
	}

}
