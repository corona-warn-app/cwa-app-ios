//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinSelectionCellModelTests: CWATestCase {

	func testInitialSetup() {
		let description = "Very Nice Trace Location"
		let address = "Trace Location Address"

		let checkin: Checkin = .mock(
			traceLocationDescription: description,
			traceLocationAddress: address
		)

		let cellModel = CheckinSelectionCellModel(checkin: checkin)

		XCTAssertEqual(cellModel.checkin, checkin)
		XCTAssertEqual(cellModel.description, description)
		XCTAssertEqual(cellModel.address, address)
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
