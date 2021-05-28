////
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayNotesInfoViewModelTest: CWATestCase {
	
	private func createVC() -> DiaryDayNotesInfoViewController {
		DiaryDayNotesInfoViewController(onDismiss: {})
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
}
