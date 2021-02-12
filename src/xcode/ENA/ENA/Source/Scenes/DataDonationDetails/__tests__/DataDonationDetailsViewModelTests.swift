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

	func testReuseIdentifierCell2() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell2 = tableViewModel.section(0).cells[2]
		// THEN
		XCTAssertEqual(cell2.cellReuseIdentifier.rawValue, "roundedCell")
	}

	func testReuseIdentifierCell34() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell34 = tableViewModel.section(0).cells[34]
		// THEN
		XCTAssertEqual(cell34.cellReuseIdentifier.rawValue, "bulletPointCell")
	}

	func testReuseIdentifierCell35() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell35 = tableViewModel.section(0).cells[35]
		// THEN
		XCTAssertEqual(cell35.cellReuseIdentifier.rawValue, "labelCell")
	}

}
