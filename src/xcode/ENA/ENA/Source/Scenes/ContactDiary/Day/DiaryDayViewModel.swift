////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryDayViewModel {

	// MARK: - Init

	init(
		day: DiaryDay,
		store: DiaryStoringProviding,
		onAddEntryCellTap: @escaping (DiaryDay, DiaryEntryType) -> Void
	) {
		self.day = day
		self.store = store
		self.onAddEntryCellTap = onAddEntryCellTap

		store.diaryDaysPublisher
			.sink { [weak self] days in
				guard let day = days.first(where: { $0.dateString == day.dateString }) else { return }

				self?.day = day
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case add
		case entries
	}

	@OpenCombine.Published private(set) var day: DiaryDay
	@OpenCombine.Published var selectedEntryType: DiaryEntryType = .contactPerson

	var entriesOfSelectedType: [DiaryEntry] {
		day.entries.filter {
			$0.type == selectedEntryType
		}
	}

	var numberOfSections: Int {
		Section.allCases.count
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .add:
			return 1
		case .entries:
			return entriesOfSelectedType.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func didTapAddEntryCell() {
		onAddEntryCellTap(day, selectedEntryType)
	}

	func toggleSelection(at indexPath: IndexPath) {
		guard Section(rawValue: indexPath.section) == .entries else {
			fatalError("Cannot toggle other elements outside the entries section")
		}

		toggleSelection(of: entriesOfSelectedType[indexPath.row])
	}

	// MARK: - Private

	private let store: DiaryStoringProviding
	private let onAddEntryCellTap: (DiaryDay, DiaryEntryType) -> Void

	private var subscriptions: [AnyCancellable] = []

	private func toggleSelection(of entry: DiaryEntry) {
		entry.isSelected ? deselect(entry: entry) : select(entry: entry)
	}

	private func select(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.addLocationVisit(locationId: location.id, date: day.dateString)
		case .contactPerson(let contactPerson):
			store.addContactPersonEncounter(contactPersonId: contactPerson.id, date: day.dateString)
		}
	}

	private func deselect(entry: DiaryEntry) {
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
