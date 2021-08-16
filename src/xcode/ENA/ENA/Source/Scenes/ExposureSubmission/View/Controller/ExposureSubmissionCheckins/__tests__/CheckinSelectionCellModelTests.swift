//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinSelectionCellModelTests: CWATestCase {

	func testInitialSetup() {
		let checkin: Checkin = .mock(
			traceLocationDescription: "Very Nice Trace Location",
			traceLocationAddress: "Trace Location Address"
		)

		let cellModel = CheckinSelectionCellModel(checkin: checkin)

		XCTAssertEqual(cellModel.checkin, checkin)
		XCTAssertEqual(cellModel.description, "Very Nice Trace Location")
		XCTAssertEqual(cellModel.address, "Trace Location Address")
	}

	func testSelection() {
		let cellModel = CheckinSelectionCellModel(checkin: .mock())

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
