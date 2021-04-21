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
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .none,
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage
		let detail = cellViewModel.exposureHistoryDetail
		let titleCheckin = cellViewModel.checkinTitleHeadlineText
		let imageCheckin = cellViewModel.checkinImage
		let detailCheckin = cellViewModel.checkinDetailDescription

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertNil(title)
		XCTAssertNil(image)
		XCTAssertNil(detail)
		XCTAssertNil(titleCheckin)
		XCTAssertNil(imageCheckin)
		XCTAssertNil(detailCheckin)
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_LowOldTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.low),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage
		let titleCheckin = cellViewModel.checkinTitleHeadlineText
		let imageCheckin = cellViewModel.checkinImage
		let detailCheckin = cellViewModel.checkinDetailDescription

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.lowRiskTitle)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_low"))
		XCTAssertNil(titleCheckin)
		XCTAssertNil(imageCheckin)
		XCTAssertNil(detailCheckin)
	}

	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_HighOldTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.high),
			minimumDistinctEncountersWithHighRisk: 1,
			checkinsWithRisk: []
		)

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
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.low),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextStandardCause)
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
						traceLocationId: nil,
						visit: LocationVisit(
							id: 0,
							date: "2021-01-14",
							locationId: 1,
							checkinId: nil
						)
					)
				)
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.low),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithEntries_WHEN_zero_minimumDistinctEncountersWithHighRisk_THEN_TextLowRiskEncounters() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [
				.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounter: ContactPersonEncounter(id: 0, date: "2021-01-14", contactPersonId: 0))),
				.location(DiaryLocation(id: 1, name: "Supermarkt", traceLocationId: nil, visit: LocationVisit(id: 1, date: "2021-01-14", locationId: 1, checkinId: nil)))
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.high),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_zero_minimumDistinctEncountersWithHighRisk_THEN_TextLowRiskEncounters() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.high),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause)
	}
	
	func testGIVEN_HighEncounterDayWithEntries_WHEN_one_minimumDistinctEncountersWithHighRisk_THEN_TextStandard() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [
				.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounter: ContactPersonEncounter(id: 0, date: "2021-01-14", contactPersonId: 0))),
				.location(DiaryLocation(id: 1, name: "Supermarkt", traceLocationId: nil, visit: LocationVisit(id: 1, date: "2021-01-14", locationId: 1, checkinId: nil)))
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.high),
			minimumDistinctEncountersWithHighRisk: 1,
			checkinsWithRisk: []
		)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_multiple_minimumDistinctEncountersWithHighRisk_THEN_TextStandard() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .encounter(.high),
			minimumDistinctEncountersWithHighRisk: 2,
			checkinsWithRisk: []
		)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextStandardCause)
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
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: DiaryDay(dateString: "", entries: []),
			historyExposure: .encounter(.low),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)
		let detailText = cellViewModel.entryDetailTextFor(personEncounter: personEncounter)

		XCTAssertEqual(detailText, "\(AppStrings.ContactDiary.Overview.PersonEncounter.durationMoreThan15Minutes), \(AppStrings.ContactDiary.Overview.PersonEncounter.maskSituationWithMask), \(AppStrings.ContactDiary.Overview.PersonEncounter.settingInside)")
	}

	func testGIVEN_LocationVisit_THEN_CorrectEntryDetailTextIsReturned() {
		// GIVEN
		let locationVisit = LocationVisit(id: 0, date: "2021-01-14", locationId: 0, durationInMinutes: 3 * 60 + 42, circumstances: "", checkinId: nil)
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: DiaryDay(dateString: "", entries: []),
			historyExposure: .encounter(.low),
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: []
		)
		let detailText = cellViewModel.entryDetailTextFor(locationVisit: locationVisit)

		XCTAssertEqual(detailText, "03:42 \(AppStrings.ContactDiary.Overview.LocationVisit.abbreviationHours)")
	}
	
	func testGIVEN_RiskyCheckins_WHEN_ContainsOneLow_THEN_LowAttributesAreShown() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-03-29",
			entries: []
		)
		
		let checkinWithRisk = [CheckinWithRisk(checkIn: Checkin.mock(), risk: .low)]
		
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .none,
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: checkinWithRisk
		)

		// WHEN
		let hideCheckinRisk = cellViewModel.hideCheckinRisk
		let title = cellViewModel.checkinTitleHeadlineText
		let details = cellViewModel.checkinDetailDescription
		let image = cellViewModel.checkinImage
		let isJustOneEntry = cellViewModel.isSinlgeRiskyCheckin
		let accessibilityIdentifier = cellViewModel.checkinTitleAccessibilityIdentifier

		// THEN
		XCTAssertFalse(hideCheckinRisk)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.CheckinEncounter.titleLowRisk)
		XCTAssertEqual(details, AppStrings.ContactDiary.Overview.CheckinEncounter.titleSubheadline)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_low"))
		XCTAssertTrue(isJustOneEntry)
		XCTAssertEqual(accessibilityIdentifier, AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelLow)
	}
	
	func testGIVEN_RiskyCheckins_WHEN_ContainsOneHigh_THEN_HighAttributesAreShown() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-03-29",
			entries: []
		)
		
		let checkinWithRisk = [CheckinWithRisk(checkIn: Checkin.mock(), risk: .low), CheckinWithRisk(checkIn: Checkin.mock(), risk: .high)]
		
		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .none,
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: checkinWithRisk
		)

		// WHEN
		let hideCheckinRisk = cellViewModel.hideCheckinRisk
		let title = cellViewModel.checkinTitleHeadlineText
		let details = cellViewModel.checkinDetailDescription
		let image = cellViewModel.checkinImage
		let isJustOneEntry = cellViewModel.isSinlgeRiskyCheckin
		let accessibilityIdentifier = cellViewModel.checkinTitleAccessibilityIdentifier

		// THEN
		XCTAssertFalse(hideCheckinRisk)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.CheckinEncounter.titleHighRisk)
		XCTAssertEqual(details, AppStrings.ContactDiary.Overview.CheckinEncounter.titleSubheadline)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_high"))
		XCTAssertFalse(isJustOneEntry)
		XCTAssertEqual(accessibilityIdentifier, AccessibilityIdentifiers.ContactDiaryInformation.Overview.checkinRiskLevelHigh)
	}
	
	func testGIVEN_RiskyCheckins_WHEN_ContainsSomeCheckins_THEN_ListIsConstructed() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-03-29",
			entries: []
		)
		let descriptionLow = "Kiosk"
		let descriptionHigh = "Privates Treffen"
		
		let checkinWithRiskLow = CheckinWithRisk(checkIn: Checkin.mock(traceLocationDescription: descriptionLow), risk: .low)
		let checkinWithRiskHigh = CheckinWithRisk(checkIn: Checkin.mock(traceLocationDescription: descriptionHigh), risk: .high)

		let cellViewModel = DiaryOverviewDayCellModel(
			diaryDay: diaryDay,
			historyExposure: .none,
			minimumDistinctEncountersWithHighRisk: 0,
			checkinsWithRisk: [checkinWithRiskLow, checkinWithRiskHigh]
		)

		// WHEN
		let checkinWithRiskLowDescription = cellViewModel.checkInDespription(checkinWithRisk: checkinWithRiskLow)
		let checkinWithRiskHighDescription = cellViewModel.checkInDespription(checkinWithRisk: checkinWithRiskHigh)

		let colorForCheckinWithRiskLow = cellViewModel.colorFor(riskLevel: checkinWithRiskLow.risk)
		let colorForCheckinWithRiskHigh = cellViewModel.colorFor(riskLevel: checkinWithRiskHigh.risk)


		// THEN
		let suffixLowRisk = AppStrings.ContactDiary.Overview.CheckinEncounter.lowRisk
		let suffixHighRisk = AppStrings.ContactDiary.Overview.CheckinEncounter.highRisk
		XCTAssertEqual(checkinWithRiskLowDescription, descriptionLow + " \(suffixLowRisk)")
		XCTAssertEqual(checkinWithRiskHighDescription, descriptionHigh + " \(suffixHighRisk)")
		XCTAssertEqual(colorForCheckinWithRiskLow, .enaColor(for: .textPrimary2))
		XCTAssertEqual(colorForCheckinWithRiskHigh, .enaColor(for: .riskHigh))
	}
}
