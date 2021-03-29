////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class EditCheckinDetailViewModelTests: XCTestCase {

	func testGIVEN_EditCheckinDetailViewModel_THEN_ValueMatch() {
		let startDate = Date(timeIntervalSince1970: 1616074184)
		let endDate = Date(timeIntervalSince1970: 1616094184)
		// GIVEN
		let checkIn = Checkin.mock(
			traceLocationType: .locationTypeTemporaryClubActivity,
			traceLocationDescription: "Jahrestreffen der deutschen SAP Anwendergruppe",
			traceLocationAddress: "Hauptstr 3, 69115 Heidelberg",
			checkinStartDate: startDate,
			checkinEndDate: endDate
		)
		let eventStore = MockEventStore()

		let editCheckinDetailViewModel = EditCheckinDetailViewModel(
			checkIn,
			eventStore: eventStore
		)

		// THEN
		XCTAssertNotNil(editCheckinDetailViewModel.checkInDescriptionCellModel)
		XCTAssertNotNil(editCheckinDetailViewModel.checkInStartCellModel)
		XCTAssertNotNil(editCheckinDetailViewModel.checkInEndCellModel)
		XCTAssertFalse(editCheckinDetailViewModel.isStartDatePickerVisible)
		XCTAssertFalse(editCheckinDetailViewModel.isEndDatePickerVisible)
		XCTAssertLessThanOrEqual(editCheckinDetailViewModel.startDate, startDate)
		XCTAssertLessThanOrEqual(editCheckinDetailViewModel.endDate, endDate)
	}
}
