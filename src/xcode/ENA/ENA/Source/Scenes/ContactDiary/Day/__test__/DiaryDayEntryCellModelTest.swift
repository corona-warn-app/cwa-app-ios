//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
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

	func testSelectedSettingSegmentIndexForNone() {
		let cellModel = contactPersonCellModelWithEncounter(setting: .none)

		XCTAssertEqual(cellModel.selectedSettingSegmentIndex, -1)
	}

	func testSelectedSettingSegmentIndexForOutside() {
		let cellModel = contactPersonCellModelWithEncounter(setting: .outside)

		XCTAssertEqual(cellModel.selectedSettingSegmentIndex, 0)
	}

	func testSelectedSettingSegmentIndexForInside() {
		let cellModel = contactPersonCellModelWithEncounter(setting: .inside)

		XCTAssertEqual(cellModel.selectedSettingSegmentIndex, 1)
	}

	func testSelectedSettingSegmentIndexWithoutEncounter() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		XCTAssertEqual(cellModel.selectedSettingSegmentIndex, -1)
	}

	func testSelectedSettingSegmentIndexOnLocation() {
		let cellModel = locationCellModelWithVisit()

		XCTAssertEqual(cellModel.selectedSettingSegmentIndex, -1)
	}

	func testLocationVisitDurationWithValue() {
		let cellModel = locationCellModelWithVisit(durationInMinutes: 17)

		XCTAssertEqual(cellModel.locationVisitDuration, 17)
	}

	func testLocationVisitDurationWithoutVisit() {
		let cellModel = locationCellModelWithoutVisit()

		XCTAssertEqual(cellModel.locationVisitDuration, 0)
	}

	func testLocationVisitDurationOnContactPerson() {
		let cellModel = contactPersonCellModelWithEncounter()

		XCTAssertEqual(cellModel.locationVisitDuration, 0)
	}

	func testContactPersonCircumstancesWithEncounter() {
		let cellModel = contactPersonCellModelWithEncounter(circumstances: "Circumstances")

		XCTAssertEqual(cellModel.circumstances, "Circumstances")
	}

	func testContactPersonCircumstancesWithoutEncounter() {
		let cellModel = contactPersonCellModelWithoutEncounter()

		XCTAssertEqual(cellModel.circumstances, "")
	}

	func testLocationCircumstancesWithVisit() {
		let cellModel = locationCellModelWithVisit(circumstances: "Circumstances")

		XCTAssertEqual(cellModel.circumstances, "Circumstances")
	}

	func testLocationCircumstancesWithoutVisit() {
		let cellModel = locationCellModelWithoutVisit()

		XCTAssertEqual(cellModel.circumstances, "")
	}

	func testContactPersonSelection() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithoutEncounter(store: store)

		cellModel.toggleSelection()

		XCTAssertNotNil(firstContactPerson(in: store).encounter)
	}

	func testContactPersonDeselection() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store)

		cellModel.toggleSelection()

		XCTAssertNil(firstContactPerson(in: store).encounter)
	}

	func testLocationSelection() {
		let store = MockDiaryStore()
		let cellModel = locationCellModelWithoutVisit(store: store)

		cellModel.toggleSelection()

		XCTAssertNotNil(firstLocation(in: store).visit)
	}

	func testLocationDeselection() {
		let store = MockDiaryStore()
		let cellModel = locationCellModelWithVisit(store: store)

		cellModel.toggleSelection()

		XCTAssertNil(firstLocation(in: store).visit)
	}

	func testSelectingDurationNone() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, duration: .lessThan15Minutes)

		cellModel.selectDuration(at: -1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.duration, ContactPersonEncounter.Duration.none)
	}

	func testSelectingDurationLessThan15Minutes() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, duration: .none)

		cellModel.selectDuration(at: 0)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.duration, ContactPersonEncounter.Duration.lessThan15Minutes)
	}

	func testSelectingDurationMoreThan15Minutes() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, duration: .none)

		cellModel.selectDuration(at: 1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.duration, ContactPersonEncounter.Duration.moreThan15Minutes)
	}

	func testSelectingMaskSituationNone() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, maskSituation: .withMask)

		cellModel.selectMaskSituation(at: -1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.maskSituation, ContactPersonEncounter.MaskSituation.none)
	}

	func testSelectingMaskSituationWithMask() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, maskSituation: .none)

		cellModel.selectMaskSituation(at: 0)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.maskSituation, ContactPersonEncounter.MaskSituation.withMask)
	}

	func testSelectingMaskSituationWithoutMask() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, maskSituation: .none)

		cellModel.selectMaskSituation(at: 1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.maskSituation, ContactPersonEncounter.MaskSituation.withoutMask)
	}

	func testSelectingSettingNone() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, setting: .outside)

		cellModel.selectSetting(at: -1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.setting, ContactPersonEncounter.Setting.none)
	}

	func testSelectingSettingOutside() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, setting: .none)

		cellModel.selectSetting(at: 0)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.setting, ContactPersonEncounter.Setting.outside)
	}

	func testSelectingSettingInside() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, setting: .none)

		cellModel.selectSetting(at: 1)

		XCTAssertEqual(firstContactPerson(in: store).encounter?.setting, ContactPersonEncounter.Setting.inside)
	}

	func testUpdatingEncounterCircumstances() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(store: store, circumstances: "")

		cellModel.updateContactPersonEncounter(circumstances: "New Circumstances")

		XCTAssertEqual(firstContactPerson(in: store).encounter?.circumstances, "New Circumstances")
	}

	func testUpdatingVisitCircumstances() {
		let store = MockDiaryStore()
		let cellModel = locationCellModelWithVisit(store: store, circumstances: "")

		cellModel.updateLocationVisit(durationInMinutes: cellModel.locationVisitDuration, circumstances: "New Circumstances")

		XCTAssertEqual(firstLocation(in: store).visit?.circumstances, "New Circumstances")
	}

	func testUpdatingContactPersonEncounter() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(
			store: store,
			duration: .none,
			maskSituation: .none,
			setting: .none,
			circumstances: ""
		)

		cellModel.updateContactPersonEncounter(
			duration: .lessThan15Minutes,
			maskSituation: .withMask,
			setting: .outside,
			circumstances: "Circumstances"
		)

		let encounter = firstContactPerson(in: store).encounter

		XCTAssertEqual(encounter?.duration, .lessThan15Minutes)
		XCTAssertEqual(encounter?.maskSituation, .withMask)
		XCTAssertEqual(encounter?.setting, .outside)
		XCTAssertEqual(encounter?.circumstances, "Circumstances")
	}

	func testUpdatingContactPersonEncounterKeepsOldValues() {
		let store = MockDiaryStore()
		let cellModel = contactPersonCellModelWithEncounter(
			store: store,
			duration: .lessThan15Minutes,
			maskSituation: .withMask,
			setting: .outside,
			circumstances: "Circumstances"
		)

		cellModel.updateContactPersonEncounter()

		let encounter = firstContactPerson(in: store).encounter

		XCTAssertEqual(encounter?.duration, .lessThan15Minutes)
		XCTAssertEqual(encounter?.maskSituation, .withMask)
		XCTAssertEqual(encounter?.setting, .outside)
		XCTAssertEqual(encounter?.circumstances, "Circumstances")
	}

	func testUpdatingLocationVisit() {
		let store = MockDiaryStore()
		let cellModel = locationCellModelWithVisit(
			store: store,
			durationInMinutes: 0,
			circumstances: ""
		)

		cellModel.updateLocationVisit(
			durationInMinutes: 17,
			circumstances: "Circumstances"
		)

		let visit = firstLocation(in: store).visit

		XCTAssertEqual(visit?.durationInMinutes, 17)
		XCTAssertEqual(visit?.circumstances, "Circumstances")
	}

	func testUpdatingLocationVisitKeepsOldValues() {
		let store = MockDiaryStore()
		let cellModel = locationCellModelWithVisit(
			store: store,
			durationInMinutes: 17,
			circumstances: "Circumstances"
		)

		cellModel.updateLocationVisit(durationInMinutes: cellModel.locationVisitDuration, circumstances: cellModel.circumstances)

		let visit = firstLocation(in: store).visit

		XCTAssertEqual(visit?.durationInMinutes, 17)
		XCTAssertEqual(visit?.circumstances, "Circumstances")
	}

	// MARK: - Private

	private func contactPersonCellModelWithoutEncounter(
		store: DiaryStoringProviding = MockDiaryStore(),
		name: String = ""
	) -> DiaryDayEntryCellModel {
		let result = store.addContactPerson(name: name)

		guard case .success(let id) = result else {
			fatalError("Could not add person")
		}

		return DiaryDayEntryCellModel(
			entry: .contactPerson(
				DiaryContactPerson(
					id: id,
					name: name
				)
			),
			dateString: todayString,
			store: store
		)
	}

	private func contactPersonCellModelWithEncounter(
		store: DiaryStoringProviding = MockDiaryStore(),
		name: String = "",
		duration: ContactPersonEncounter.Duration = .none,
		maskSituation: ContactPersonEncounter.MaskSituation = .none,
		setting: ContactPersonEncounter.Setting = .none,
		circumstances: String = ""
	) -> DiaryDayEntryCellModel {
		var result = store.addContactPerson(name: name)

		guard case .success(let contactPersonID) = result else {
			fatalError("Could not add person")
		}

		result = store.addContactPersonEncounter(contactPersonId: contactPersonID, date: todayString)

		guard case .success(let encounterID) = result else {
			fatalError("Could not add encounter")
		}

		return DiaryDayEntryCellModel(
			entry: .contactPerson(
				DiaryContactPerson(
					id: contactPersonID,
					name: name,
					encounter: ContactPersonEncounter(
						id: encounterID,
						date: todayString,
						contactPersonId: contactPersonID,
						duration: duration,
						maskSituation: maskSituation,
						setting: setting,
						circumstances: circumstances
					)
				)
			),
			dateString: todayString,
			store: store
		)
	}

	private func locationCellModelWithoutVisit(
		store: DiaryStoringProviding = MockDiaryStore(),
		name: String = ""
	) -> DiaryDayEntryCellModel {
		let result = store.addLocation(name: name)

		guard case .success(let id) = result else {
			fatalError("Could not add location")
		}

		return DiaryDayEntryCellModel(
			entry: .location(
				DiaryLocation(
					id: id,
					name: name,
					traceLocationId: nil
				)
			),
			dateString: todayString,
			store: store
		)
	}

	private func locationCellModelWithVisit(
		store: DiaryStoringProviding = MockDiaryStore(),
		name: String = "",
		durationInMinutes: Int = 0,
		circumstances: String = ""
	) -> DiaryDayEntryCellModel {
		var result = store.addLocation(name: name)

		guard case .success(let locationID) = result else {
			fatalError("Could not add location")
		}

		result = store.addLocationVisit(locationId: locationID, date: todayString)

		guard case .success(let visitID) = result else {
			fatalError("Could not add visit")
		}

		return DiaryDayEntryCellModel(
			entry: .location(
				DiaryLocation(
					id: locationID,
					name: name,
					traceLocationId: nil,
					visit: LocationVisit(
						id: visitID,
						date: todayString,
						locationId: locationID,
						durationInMinutes: durationInMinutes,
						circumstances: circumstances,
						checkinId: nil
					)
				)
			),
			dateString: todayString,
			store: store
		)
	}

	private func firstContactPerson(in store: DiaryStoringProviding) -> DiaryContactPerson {
		guard let today = store.diaryDaysPublisher.value.first(where: { $0.dateString == todayString }),
			  let firstEntry = today.entries.first(where: { $0.type == .contactPerson }),
			  case .contactPerson(let contactPerson) = firstEntry
		else {
			fatalError("Could not find contactPerson")
		}

		return contactPerson
	}

	private func firstLocation(in store: DiaryStoringProviding) -> DiaryLocation {
		guard let today = store.diaryDaysPublisher.value.first(where: { $0.dateString == todayString }),
			  let firstEntry = today.entries.first(where: { $0.type == .location }),
			  case .location(let location) = firstEntry
		else {
			fatalError("Could not find location")
		}

		return location
	}

	private var todayString: String = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]

		return dateFormatter.string(from: Date())
	}()
	
}
