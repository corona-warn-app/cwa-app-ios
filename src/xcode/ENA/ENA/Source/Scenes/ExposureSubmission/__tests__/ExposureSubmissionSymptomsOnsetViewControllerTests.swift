//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ExposureSubmissionSymptomsOnsetViewControllerTests: XCTestCase {

	private func createVC() -> ExposureSubmissionSymptomsOnsetViewController {
		ExposureSubmissionSymptomsOnsetViewController(onPrimaryButtonTap: { _, _ in }, onDismiss: { _ in })
	}

	func testCellsOnScreen() {
		let vc = createVC()
		_ = vc.view

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
		XCTAssertEqual(id.rawValue, "optionGroupCell")
	}

}
