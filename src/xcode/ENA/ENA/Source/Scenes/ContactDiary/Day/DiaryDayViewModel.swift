////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryDayViewModel {

	// MARK: - Init

	init(day: DiaryDay, store: DiaryStoring) {
		self.day = day
		self.store = store

		store.diaryDaysPublisher
			.sink { [weak self] days in
				guard let day = days.first(where: { $0.dateString == day.dateString }) else { return }

				self?.day = day
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int {
		case add
		case entries
	}

	@Published private(set) var day: DiaryDay
	@Published var selectedEntryType: DiaryEntryType = .contactPerson

	var entriesOfSelectedType: [DiaryEntry] {
		day.entries.filter {
			$0.type == selectedEntryType
		}
	}

	func toggleSelection(at indexPath: IndexPath) {
		guard Section(rawValue: indexPath.section) == .entries else {
			fatalError("Cannot toggle other elements outside the entries section")
		}

		toggleSelection(of: entriesOfSelectedType[indexPath.row])
	}

	// MARK: - Private

	private let store: DiaryStoring

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
			guard let visitId = location.visitId else {
				Log.error("Trying to deselect unselected location", log: .contactdiary)
				return
			}
			store.removeLocationVisit(id: visitId)
		case .contactPerson(let contactPerson):
			guard let encounterId = contactPerson.encounterId else {
				Log.error("Trying to deselect unselected contact person", log: .contactdiary)
				return
			}
			store.removeContactPersonEncounter(id: encounterId)
		}
	}

}
