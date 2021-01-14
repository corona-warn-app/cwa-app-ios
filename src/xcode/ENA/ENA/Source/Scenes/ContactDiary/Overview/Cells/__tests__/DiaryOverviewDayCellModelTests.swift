////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DiaryOverviewDayCellModelTests: XCTestCase {

	func testGIVEN_NoEncounterDay_WHEN_getTitle_THEN_TextsAreNilAndAnEmptyImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [],
			exposureEncounter: .none
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.showExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertNil(title)
		XCTAssertEqual(image, UIImage())
		XCTAssertNil(detail)
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_LowAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [],
			exposureEncounter: .encounter(.low)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.showExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertEqual(title, "Niedriges Risiko")
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_low"))
	}

	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_HighAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [],
			exposureEncounter: .encounter(.high)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.showExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertEqual(title, "Erhöhtes Risiko")
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_high"))
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getDetail_THEN_isShorterDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [],
			exposureEncounter: .encounter(.low)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.showExposureHistory
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertEqual(detail, "aufgrund der von der App ausgewerteten Begegnungen.")
	}

	func testGIVEN_LowEncounterDayWithEntries_WHEN_getDetail_THEN_isLongerDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2020-12-16",
			entries: [
				.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounterId: 0)),
				.location(DiaryLocation(id: 1, name: "Supermarkt", visitId: 0))
			],
			exposureEncounter: .encounter(.low)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, "aufgrund der von der App ausgewerteten Begegnungen.\nDiese müssen nicht in Zusammenhang mit den von Ihnen erfassten Personen und Orten stehen.")
	}
}
