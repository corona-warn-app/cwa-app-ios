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

}
