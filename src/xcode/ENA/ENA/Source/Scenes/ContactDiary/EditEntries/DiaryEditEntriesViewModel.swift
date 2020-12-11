//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

class DiaryEditEntriesViewModel {

	// MARK: - Init

	init(
		entryType: DiaryEntryType,
		store: DiaryStoring
	) {
		self.entryType = entryType
		self.store = store
		self.entries = []

		store.diaryDaysPublisher
			.sink { [weak self] days in
				guard let firstDay = days.first else { return }

				self?.entries = firstDay.entries.filter {
					$0.type == entryType
				}
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	@Published private(set) var entries: [DiaryEntry]

	var title: String {
		""
	}

	func remove(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.removeLocation(id: location.id)
		case .contactPerson(let contactPerson):
			store.removeContactPerson(id: contactPerson.id)
		}
	}

	func removeAll(entryType: DiaryEntryType) {
		switch entryType {
		case .location:
			store.removeAllLocations()
		case .contactPerson:
			store.removeAllContactPersons()
		}
	}

	// MARK: - Private

	private let entryType: DiaryEntryType
	private let store: DiaryStoring

	private var subscriptions: [AnyCancellable] = []

}
