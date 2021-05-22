////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckInDescriptionCellModelTests: XCTestCase {

	func testGIVEN_CheckInDescriptionCellModel_THEN_ValueMatch() {
		// GIVEN
		let checkIn = Checkin.mock(
			traceLocationType: .locationTypeTemporaryClubActivity,
			traceLocationDescription: "Jahrestreffen der deutschen SAP Anwendergruppe",
			traceLocationAddress: "Hauptstr 3, 69115 Heidelberg"
		)
		let checkInDescriptionCellModel = CheckInDescriptionCellModel(checkIn: checkIn)

		// THEN
		XCTAssertEqual(checkInDescriptionCellModel.locationType, TraceLocationType.locationTypeTemporaryClubActivity.title)
		XCTAssertEqual(checkInDescriptionCellModel.description, "Jahrestreffen der deutschen SAP Anwendergruppe")
		XCTAssertEqual(checkInDescriptionCellModel.address, "Hauptstr 3, 69115 Heidelberg")
	}
}
