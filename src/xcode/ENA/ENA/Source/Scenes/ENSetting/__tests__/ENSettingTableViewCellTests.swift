////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ENSettingTableViewCellTests: XCTestCase {
	
	func testDaysSinceInstallTableViewCell() {
		let cell = DaysSinceInstallTableViewCell()
		XCTAssertNotNil(cell)
	}
	
	func testImageTableViewCell() {
		let cell = ImageTableViewCell()
		XCTAssertNotNil(cell)
	}
	
	func testDescriptionTableViewCell() {
		let cell = DescriptionTableViewCell()
		XCTAssertNotNil(cell)
	}
	
	func testActionTableViewCell() {
		let cell = ActionTableViewCell()
		XCTAssertNotNil(cell)
	}
	
	func testEuTracingTableViewCell() {
		let cell = EuTracingTableViewCell()
		XCTAssertNotNil(cell)
	}
	
	func testActionDetailTableViewCell() {
		let cell = ActionDetailTableViewCell()
		XCTAssertNotNil(cell)
	}
}
