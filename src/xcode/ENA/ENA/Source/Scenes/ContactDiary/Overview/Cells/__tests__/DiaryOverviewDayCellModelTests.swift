////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DiaryOverviewDayCellModelTests: XCTestCase {

	func testGIVEN_NoEncounterDay_WHEN_getTitle_THEN_TextsAreNilAndAnEmptyImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [],
			exposureEncounter: .none
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertNil(title)
		XCTAssertNil(image)
		XCTAssertNil(detail)
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_LowAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [],
			exposureEncounter: .encounter(.low)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.lowRiskTitle)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_low"))
	}

	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_HighAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [],
			exposureEncounter: .encounter(.high)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.increasedRiskTitle)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_high"))
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getDetail_THEN_isShorterDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [],
			exposureEncounter: .encounter(.low)
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskText1)
	}

	func testGIVEN_LowEncounterDayWithEntries_WHEN_getDetail_THEN_isLongerDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
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
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskText1, AppStrings.ContactDiary.Overview.riskText2].joined(separator: "\n"))
	}
}
