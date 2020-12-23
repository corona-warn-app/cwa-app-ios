//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionTestResultConsentViewModelTests: XCTestCase {

	func testCellsInSection0() {
		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			exposureSubmissionService: MockExposureSubmissionService(),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)

		let section = viewModel.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 4)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let fourthItem = cells[2]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "ConsentCellReuseIdentifier")
		
		let fifthItem = cells[3]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")
		
	}
	
	func testCellsInSection1() {
		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			exposureSubmissionService: MockExposureSubmissionService(),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)
		
		let section = viewModel.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
		
	}
	
	func testCellsInSection2() {
		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			exposureSubmissionService: MockExposureSubmissionService(),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)
		
		let section = viewModel.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

	}
	
}
