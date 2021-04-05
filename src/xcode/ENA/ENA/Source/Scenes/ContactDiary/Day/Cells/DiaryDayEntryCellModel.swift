////
// 🦠 Corona-Warn-App
//

import UIKit

struct DiaryDayEntryCellModel {

	// MARK: - Init

	init(
		entry: DiaryEntry,
		dateString: String,
		store: DiaryStoringProviding
	) {
		self.entry = entry
		self.dateString = dateString
		self.store = store

		image = entry.isSelected ? UIImage(named: "Diary_Checkmark_Selected") : UIImage(named: "Diary_Checkmark_Unselected")
		text = entry.name
		font = entry.isSelected ? .enaFont(for: .headline) : .enaFont(for: .body)

		entryType = entry.type
		parametersHidden = !entry.isSelected

		if entry.isSelected {
			accessibilityTraits = [.button, .selected]
		} else {
			accessibilityTraits = [.button]
		}
	}

	// MARK: - Internal

	struct SegmentedControlValue<T: Equatable>: Equatable {
		let title: String
		let value: T
	}

	let image: UIImage?
	let text: String
	let font: UIFont

	let entryType: DiaryEntryType
	let parametersHidden: Bool

	let accessibilityTraits: UIAccessibilityTraits

	let durationValues: [SegmentedControlValue<ContactPersonEncounter.Duration>] = [
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.lessThan15Minutes, value: .lessThan15Minutes),
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.moreThan15Minutes, value: .moreThan15Minutes)
	]

	var selectedDurationSegmentIndex: Int {
		guard case .contactPerson(let contactPerson) = entry, let encounter = contactPerson.encounter else {
			return -1
		}

		return durationValues.firstIndex { $0.value == encounter.duration } ?? -1
	}

	let maskSituationValues: [SegmentedControlValue<ContactPersonEncounter.MaskSituation>] = [
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.withMask, value: .withMask),
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.withoutMask, value: .withoutMask)
	]

	var selectedMaskSituationSegmentIndex: Int {
		guard case .contactPerson(let contactPerson) = entry, let encounter = contactPerson.encounter else {
			return -1
		}

		return maskSituationValues.firstIndex { $0.value == encounter.maskSituation } ?? -1
	}

	let settingValues: [SegmentedControlValue<ContactPersonEncounter.Setting>] = [
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.outside, value: .outside),
		SegmentedControlValue(title: AppStrings.ContactDiary.Day.Encounter.inside, value: .inside)
	]

	var selectedSettingSegmentIndex: Int {
		guard case .contactPerson(let contactPerson) = entry, let encounter = contactPerson.encounter else {
			return -1
		}

		return settingValues.firstIndex { $0.value == encounter.setting } ?? -1
	}

	var locationVisitDuration: Int {
		guard case .location(let location) = entry, let visit = location.visit else {
			return 0
		}

		return visit.durationInMinutes
	}

	var circumstances: String {
		switch entry {
		case .contactPerson(let contactPerson):
			return contactPerson.encounter?.circumstances ?? ""
		case .location(let location):
			return location.visit?.circumstances ?? ""
		}
	}

	func toggleSelection() {
		entry.isSelected ? deselect() : select()
	}

	func selectDuration(at index: Int) {
		let duration: ContactPersonEncounter.Duration

		if index == -1 {
			duration = .none
		} else {
			duration = durationValues[index].value
		}

		updateContactPersonEncounter(duration: duration)
	}

	func selectMaskSituation(at index: Int) {
		let maskSituation: ContactPersonEncounter.MaskSituation

		if index == -1 {
			maskSituation = .none
		} else {
			maskSituation = maskSituationValues[index].value
		}

		updateContactPersonEncounter(maskSituation: maskSituation)
	}

	func selectSetting(at index: Int) {
		let setting: ContactPersonEncounter.Setting

		if index == -1 {
			setting = .none
		} else {
			setting = settingValues[index].value
		}

		updateContactPersonEncounter(setting: setting)
	}

	func updateContactPersonEncounter(
		duration: ContactPersonEncounter.Duration? = nil,
		maskSituation: ContactPersonEncounter.MaskSituation? = nil,
		setting: ContactPersonEncounter.Setting? = nil,
		circumstances: String? = nil
	) {
		guard case .contactPerson(let contactPerson) = entry, let encounter = contactPerson.encounter else {
			fatalError("Cannot update non-existent encounter.")
		}

		store.updateContactPersonEncounter(
			id: encounter.id,
			date: encounter.date,
			duration: duration ?? encounter.duration,
			maskSituation: maskSituation ?? encounter.maskSituation,
			setting: setting ?? encounter.setting,
			circumstances: circumstances ?? encounter.circumstances
		)
	}

	func updateLocationVisit(
		durationInMinutes: Int,
		circumstances: String
	) {
		guard case .location(let location) = entry, let visit = location.visit else {
			fatalError("Cannot update non-existent visit.")
		}

		store.updateLocationVisit(
			id: visit.id,
			date: visit.date,
			durationInMinutes: durationInMinutes,
			circumstances: circumstances
		)
	}

	// MARK: - Private

	private let entry: DiaryEntry
	private let store: DiaryStoringProviding
	private let dateString: String

	private func select() {
		switch entry {
		case .location(let location):
			store.addLocationVisit(locationId: location.id, date: dateString)
		case .contactPerson(let contactPerson):
			store.addContactPersonEncounter(contactPersonId: contactPerson.id, date: dateString)
		}
	}

	private func deselect() {
		switch entry {
		case .location(let location):
			guard let visit = location.visit else {
				Log.error("Trying to deselect unselected location", log: .contactdiary)
				return
			}
			store.removeLocationVisit(id: visit.id)
		case .contactPerson(let contactPerson):
			guard let encounter = contactPerson.encounter else {
				Log.error("Trying to deselect unselected contact person", log: .contactdiary)
				return
			}
			store.removeContactPersonEncounter(id: encounter.id)
		}
	}
    
}
