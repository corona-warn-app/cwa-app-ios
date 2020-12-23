//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DeltaOnboardingViewControllerTests: XCTestCase {

	private func createVC() -> DeltaOnboardingV15ViewController {
			DeltaOnboardingV15ViewController(
				supportedCountries: [ Country.defaultCountry() ]
			)
	}
	
	private func createVCWithoutCountries() -> DeltaOnboardingV15ViewController {
			DeltaOnboardingV15ViewController(
				supportedCountries: []
			)
	}
	
	func testCellsInSection0() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 3)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")
	}
	
	func testCellsInSection1WithCountries() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
	}
	
	func testCellsInSection1WithoutCountries() {
		let vc = createVCWithoutCountries()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 2)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
	}
	
	func testCellsInSection2WithCountries() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
		
	}
	
	func testCellsInSection2WithoutCountries() {
		let vc = createVCWithoutCountries()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 0)
	}
}
