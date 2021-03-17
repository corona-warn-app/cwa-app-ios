////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ENSettingTableViewCellTests: XCTestCase {
	
	func testDaysSinceInstallTableViewCell() {
		let cell = DaysSinceInstallTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(daysSinceInstall: 3)
		XCTAssertNotNil(cell)
	}
	
	func testImageTableViewCell() {
		let cell = ImageTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(for: .bluetoothOff)
		XCTAssertNotNil(cell)
	}
	
	func testDescriptionTableViewCell() {
		let cell = DescriptionTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(for: .bluetoothOff)
		XCTAssertNotNil(cell)
	}
	
	func testActionTableViewCell() {
		let cell = ActionTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(for: .bluetoothOff)
		XCTAssertNotNil(cell)
	}
	
	func testEuTracingTableViewCell() {
		let cell = EuTracingTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(using: ENSettingEuTracingViewModel())
		XCTAssertNotNil(cell)
	}
	
	func testActionDetailTableViewCell() {
		let cell = ActionDetailTableViewCell(style: .default, reuseIdentifier: "")
		cell.configure(for: .bluetoothOff)
		XCTAssertNotNil(cell)
	}
}
