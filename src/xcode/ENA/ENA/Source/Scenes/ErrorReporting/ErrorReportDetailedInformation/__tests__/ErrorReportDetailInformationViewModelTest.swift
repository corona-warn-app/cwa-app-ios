////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ErrorReportDetailInformationViewModelTest: XCTestCase {

	let model = ErrorReportDetailInformationViewModel()
	let totalNumberOfCells = 7
	
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModel() throws {
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
	
	func testReuseIdentifierLabelCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell0 = tableViewModel.section(0).cells[0]
		let cell4 = tableViewModel.section(0).cells[4]
		let cell6 = tableViewModel.section(0).cells[6]
		// THEN
		XCTAssertEqual(cell0.cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(cell4.cellReuseIdentifier.rawValue, "labelCell")
		XCTAssertEqual(cell6.cellReuseIdentifier.rawValue, "labelCell")
	}
	
	func testReuseIdentifierSpaceCell() throws {
		// GIVEN
		let tableViewModel = model.dynamicTableViewModel
		// WHEN
		let cell1 = tableViewModel.section(0).cells[1]
		let cell3 = tableViewModel.section(0).cells[3]
		let cell5 = tableViewModel.section(0).cells[5]
		// THEN
		XCTAssertEqual(cell1.cellReuseIdentifier.rawValue, "spaceCell")
		XCTAssertEqual(cell3.cellReuseIdentifier.rawValue, "spaceCell")
		XCTAssertEqual(cell5.cellReuseIdentifier.rawValue, "spaceCell")
	}

}
