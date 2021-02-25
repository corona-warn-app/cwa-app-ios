//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class DiaryDayEntryCellModelTest: XCTestCase {

	func testContactPersonUnselected() throws {
		let cellModel = contactPersonCellModelWithoutEncounter(name: "Nick Guendling")

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(cellModel.text, "Nick Guendling")
		XCTAssertEqual(cellModel.font, .enaFont(for: .body))

		XCTAssertEqual(cellModel.entryType, .contactPerson)
		XCTAssertTrue(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, .button)
	}

	func testContactPersonSelected() throws {
		let cellModel = contactPersonCellModelWithEncounter(name: "Marcus Scherer")

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(cellModel.text, "Marcus Scherer")
		XCTAssertEqual(cellModel.font, .enaFont(for: .headline))

		XCTAssertEqual(cellModel.entryType, .contactPerson)
		XCTAssertFalse(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, [.button, .selected])
	}

	func testLocationUnselected() throws {
		let cellModel = locationCellModelWithoutVisit(name: "Bakery")

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Unselected"))
		XCTAssertEqual(cellModel.text, "Bakery")
		XCTAssertEqual(cellModel.font, .enaFont(for: .body))

		XCTAssertEqual(cellModel.entryType, .location)
		XCTAssertTrue(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, .button)
	}

	func testLocationSelected() throws {
		let cellModel = locationCellModelWithVisit(name: "Supermarket")

		XCTAssertEqual(cellModel.image, UIImage(named: "Diary_Checkmark_Selected"))
		XCTAssertEqual(cellModel.text, "Supermarket")
		XCTAssertEqual(cellModel.font, .enaFont(for: .headline))

		XCTAssertEqual(cellModel.entryType, .location)
		XCTAssertFalse(cellModel.parametersHidden)

		XCTAssertEqual(cellModel.accessibilityTraits, [.button, .selected])
	}

	func testDurationValues() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		let expectedDurationValues: [DiaryDayEntryCellModel.SegmentedControlValue<ContactPersonEncounter.Duration>] = [
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.lessThan15Minutes,
				value: .lessThan15Minutes
			),
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.moreThan15Minutes,
				value: .moreThan15Minutes
			)
		]

		XCTAssertEqual(cellModel.durationValues, expectedDurationValues)
	}

	func testSelectedDurationSegmentIndexForNone() {
		let cellModel = contactPersonCellModelWithEncounter(duration: .none)

		XCTAssertEqual(cellModel.selectedDurationSegmentIndex, -1)
	}

	func testSelectedDurationSegmentIndexForLessThan15Minutes() {
		let cellModel = contactPersonCellModelWithEncounter(duration: .lessThan15Minutes)

		XCTAssertEqual(cellModel.selectedDurationSegmentIndex, 0)
	}

	func testSelectedDurationSegmentIndexForMoreThan15Minutes() {
		let cellModel = contactPersonCellModelWithEncounter(duration: .moreThan15Minutes)

		XCTAssertEqual(cellModel.selectedDurationSegmentIndex, 1)
	}

	func testSelectedDurationSegmentIndexWithoutEncounter() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		XCTAssertEqual(cellModel.selectedDurationSegmentIndex, -1)
	}

	func testSelectedDurationSegmentIndexOnLocation() {
		let cellModel = locationCellModelWithVisit()

		XCTAssertEqual(cellModel.selectedDurationSegmentIndex, -1)
	}

	func testMaskSituationValues() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		let expectedMaskSituationValues: [DiaryDayEntryCellModel.SegmentedControlValue<ContactPersonEncounter.MaskSituation>] = [
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.withMask,
				value: .withMask
			),
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.withoutMask,
				value: .withoutMask
			)
		]

		XCTAssertEqual(cellModel.maskSituationValues, expectedMaskSituationValues)
	}

	func testSelectedMaskSituationSegmentIndexForNone() {
		let cellModel = contactPersonCellModelWithEncounter(maskSituation: .none)

		XCTAssertEqual(cellModel.selectedMaskSituationSegmentIndex, -1)
	}

	func testSelectedMaskSituationSegmentIndexWithMask() {
		let cellModel = contactPersonCellModelWithEncounter(maskSituation: .withMask)

		XCTAssertEqual(cellModel.selectedMaskSituationSegmentIndex, 0)
	}

	func testSelectedMaskSituationSegmentIndexWithoutMask() {
		let cellModel = contactPersonCellModelWithEncounter(maskSituation: .withoutMask)

		XCTAssertEqual(cellModel.selectedMaskSituationSegmentIndex, 1)
	}

	func testSelectedMaskSituationSegmentIndexWithoutEncounter() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		XCTAssertEqual(cellModel.selectedMaskSituationSegmentIndex, -1)
	}

	func testSelectedMaskSituationSegmentIndexOnLocation() {
		let cellModel = locationCellModelWithVisit()

		XCTAssertEqual(cellModel.selectedMaskSituationSegmentIndex, -1)
	}

	func testSettingValues() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		let expectedSettingValues: [DiaryDayEntryCellModel.SegmentedControlValue<ContactPersonEncounter.Setting>] = [
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.outside,
				value: .outside
			),
			DiaryDayEntryCellModel.SegmentedControlValue(
				title: AppStrings.ContactDiary.Day.Encounter.inside,
				value: .inside
			)
		]

		XCTAssertEqual(cellModel.settingValues, expectedSettingValues)
	}

	// MARK: - Private

	private func contactPersonCellModelWithoutEncounter(name: String = "") -> DiaryDayEntryCellModel {
		return DiaryDayEntryCellModel(
			entry: .contactPerson(
				DiaryContactPerson(
					id: 0,
					name: name
				)
			),
			dateString: "2021-01-01",
			store: MockDiaryStore()
		)
	}

	private func contactPersonCellModelWithEncounter(
		name: String = "",
		duration: ContactPersonEncounter.Duration = .none,
		maskSituation: ContactPersonEncounter.MaskSituation = .none,
		setting: ContactPersonEncounter.Setting = .none,
		circumstances: String = ""
	) -> DiaryDayEntryCellModel {
		return DiaryDayEntryCellModel(
			entry: .contactPerson(
				DiaryContactPerson(
					id: 0,
					name: "Marcus Scherer",
					encounter: ContactPersonEncounter(
						id: 0,
						date: "2021-02-11",
						contactPersonId: 0,
						duration: duration,
						maskSituation: maskSituation,
						setting: setting,
						circumstances: circumstances
					)
				)
			),
			dateString: "2021-01-01",
			store: MockDiaryStore()
		)
	}

	private func locationCellModelWithoutVisit(name: String = "") -> DiaryDayEntryCellModel {
		return DiaryDayEntryCellModel(
			entry: .location(
				DiaryLocation(
					id: 0,
					name: "Bakery"
				)
			),
			dateString: "2021-01-01",
			store: MockDiaryStore()
		)
	}

	private func locationCellModelWithVisit(
		name: String = "",
		durationInMinutes: Int = 0,
		circumstances: String = ""
	) -> DiaryDayEntryCellModel {
		return DiaryDayEntryCellModel(
			entry: .location(
				DiaryLocation(
					id: 0,
					name: name,
					visit: LocationVisit(
						id: 0,
						date: "2021-02-11",
						locationId: 0,
						durationInMinutes: durationInMinutes,
						circumstances: circumstances
					)
				)
			),
			dateString: "2021-01-01",
			store: MockDiaryStore()
		)
	}
	
}
