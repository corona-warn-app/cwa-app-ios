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

		switch entryType {
		case .contactPerson:
			title = AppStrings.ContactDiary.EditEntries.ContactPersons.title
			deleteAllButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.deleteAllButtonTitle
			alertTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.Alert.title
			alertMessage = AppStrings.ContactDiary.EditEntries.ContactPersons.Alert.message
			alertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.Alert.confirmButtonTitle
			alertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.Alert.cancelButtonTitle
		case .location:
			title = AppStrings.ContactDiary.EditEntries.Locations.title
			deleteAllButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.deleteAllButtonTitle
			alertTitle = AppStrings.ContactDiary.EditEntries.Locations.Alert.title
			alertMessage = AppStrings.ContactDiary.EditEntries.Locations.Alert.message
			alertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.Alert.confirmButtonTitle
			alertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.Alert.cancelButtonTitle
		}

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

	let title: String
	let deleteAllButtonTitle: String
	let alertTitle: String
	let alertMessage: String
	let alertConfirmButtonTitle: String
	let alertCancelButtonTitle: String


	func remove(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			store.removeLocation(id: location.id)
		case .contactPerson(let contactPerson):
			store.removeContactPerson(id: contactPerson.id)
		}
	}

	func removeAll() {
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
