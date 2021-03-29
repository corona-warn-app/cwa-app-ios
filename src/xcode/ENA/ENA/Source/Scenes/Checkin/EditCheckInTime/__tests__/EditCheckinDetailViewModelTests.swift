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
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.header), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.description), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.topCorner), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.checkInStart), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.startPicker), 0)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.checkInEnd), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.endPicker), 0)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.bottomCorner), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.notice), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(EditCheckinDetailViewModel.TableViewSections(rawValue: 5000)), 0)

	}

	func testGIVEN_EditCheckinDetailViewModel_WHEN_TogglePicker_THEN_IsVisible() {
		// GIVEN
		let checkIn = Checkin.mock()
		let eventStore = MockEventStore()

		let editCheckinDetailViewModel = EditCheckinDetailViewModel(
			checkIn,
			eventStore: eventStore
		)

		// WHEN
		editCheckinDetailViewModel.toggleStartPicker()
		editCheckinDetailViewModel.toggleEndPicker()

		// THEN
		XCTAssertTrue(editCheckinDetailViewModel.isStartDatePickerVisible)
		XCTAssertTrue(editCheckinDetailViewModel.isEndDatePickerVisible)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.startPicker), 1)
		XCTAssertEqual(editCheckinDetailViewModel.numberOfRows(.endPicker), 1)
	}

}
