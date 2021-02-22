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
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .none)

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
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low))

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
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high))

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
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low))

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
				.contactPerson(
					DiaryContactPerson(
						id: 0,
						name: "Thomas Mesow",
						encounter: ContactPersonEncounter(
							id: 0,
							date: "2021-01-14",
							contactPersonId: 0
						)
					)
				),
				.location(
					DiaryLocation(
						id: 1,
						name: "Supermarkt",
						visit: LocationVisit(
							id: 0,
							date: "2021-01-14",
							locationId: 1
						)
					)
				)
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low))

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskText1, AppStrings.ContactDiary.Overview.riskText2].joined(separator: "\n"))
	}

	func testGIVEN_PersonEncounter_THEN_CorrectEntryDetailTextIsReturned() {
		// GIVEN
		let personEncounter = ContactPersonEncounter(
			id: 0,
			date: "2021-01-14",
			contactPersonId: 0,
			duration: .moreThan15Minutes,
			maskSituation: .withMask,
			setting: .inside,
			circumstances: ""
		)
		let cellViewModel = DiaryOverviewDayCellModel(DiaryDay(dateString: "", entries: []), historyExposure: .encounter(.low))
		let detailText = cellViewModel.entryDetailTextFor(personEncounter: personEncounter)

		XCTAssertEqual(detailText, "\(AppStrings.ContactDiary.PersonEncounter.durationMoreThan15Minutes), \(AppStrings.ContactDiary.PersonEncounter.maskSituationWithMask), \(AppStrings.ContactDiary.PersonEncounter.settingInside)")
	}

	func testGIVEN_LocationVisit_THEN_CorrectEntryDetailTextIsReturned() {
		// GIVEN
		let locationVisit = LocationVisit(id: 0, date: "2021-01-14", locationId: 0, durationInMinutes: 3 * 60 + 42, circumstances: "")
		let cellViewModel = DiaryOverviewDayCellModel(DiaryDay(dateString: "", entries: []), historyExposure: .encounter(.low))
		let detailText = cellViewModel.entryDetailTextFor(locationVisit: locationVisit)

		XCTAssertEqual(detailText, "03:42 \(AppStrings.ContactDiary.LocationVisit.abbreviationHours)")
	}
}
