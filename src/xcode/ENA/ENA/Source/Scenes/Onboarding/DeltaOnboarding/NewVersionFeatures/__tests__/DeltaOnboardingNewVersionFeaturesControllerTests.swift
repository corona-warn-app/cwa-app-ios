//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DeltaOnboardingNewVersionFeaturesControllerTests: CWATestCase {
	
	private func createVC() -> DeltaOnboardingNewVersionFeaturesViewController {
		let store = MockTestStore()
		return DeltaOnboardingNewVersionFeaturesViewController(finishedDeltaOnboardings: store.finishedDeltaOnboardings)
	}
	
	func testCellsInSection0() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
	}
	
	func testCellsInSection1() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(1)
		let header = section.header
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		XCTAssertNotNil(header)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
	}
}
