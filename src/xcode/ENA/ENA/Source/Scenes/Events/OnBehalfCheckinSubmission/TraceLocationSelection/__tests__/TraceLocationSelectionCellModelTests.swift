//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TraceLocationSelectionCellModelTests: CWATestCase {

	func testInitialSetup() {
		let traceLocation: TraceLocation = .mock(
			description: "Very Nice Trace Location",
			address: "Trace Location Address"
		)

		let cellModel = TraceLocationSelectionCellModel(traceLocation: traceLocation)

		XCTAssertEqual(cellModel.traceLocation, traceLocation)
		XCTAssertEqual(cellModel.description, "Very Nice Trace Location")
		XCTAssertEqual(cellModel.address, "Trace Location Address")
	}

	func testSelection() {
		let cellModel = TraceLocationSelectionCellModel(traceLocation: .mock())

		XCTAssertFalse(cellModel.cellIsSelected.value)
		XCTAssertEqual(cellModel.checkmarkImage.value, UIImage(named: "Checkin_Checkmark_Unselected"))

		cellModel.selected = true

		XCTAssertTrue(cellModel.cellIsSelected.value)
		XCTAssertEqual(cellModel.checkmarkImage.value, UIImage(named: "Checkin_Checkmark_Selected"))

		cellModel.selected = false

		XCTAssertFalse(cellModel.cellIsSelected.value)
		XCTAssertEqual(cellModel.checkmarkImage.value, UIImage(named: "Checkin_Checkmark_Unselected"))
	}

}
