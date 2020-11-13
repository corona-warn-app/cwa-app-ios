//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewSpaceCellTests: XCTestCase {
	
	func testHeight_whenHeightIsAutomaticDimension_isAutomaticDimentsion() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = UITableView.automaticDimension
		
		XCTAssertEqual(cell.height, UITableView.automaticDimension)
	}
	
	func testHeight_whenHeightIsNegative_isLeastNonzeroMagnitude() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = -42
		
		XCTAssertEqual(cell.height, .leastNonzeroMagnitude)
	}
	
	func testHeight_whenHeightIsOne_isOne() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = 1
		
		XCTAssertEqual(cell.height, 1)
	}
	
	func testHeight_whenHeightIsFourtyTwo_isFourtyTwo() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = 42
		
		XCTAssertEqual(cell.height, 42)
	}
	
	func testPrepareForReuse_setsHeightToAutomaticDimension() {
		let cell = DynamicTableViewSpaceCell()
		cell.prepareForReuse()
		
		XCTAssertEqual(cell.height, UITableView.automaticDimension)
	}
	
	func testPrepareForReuse_setsBackgroundColorToNil() {
		let cell = DynamicTableViewSpaceCell()
		cell.backgroundColor = .yellow
		cell.prepareForReuse()
		
		XCTAssertNil(cell.backgroundColor)
	}
	
	func testAccessibilityElementCount_isZero() {
		let cell = DynamicTableViewSpaceCell()
		
		XCTAssertEqual(cell.accessibilityElementCount(), 0)
	}
}
