//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class DiaryEditEntriesViewModel {

	// MARK: - Init

	init(
		entryType: DiaryEntryType,
		diaryStore: DiaryStoringProviding,
		eventStore: EventStoringProviding
	) {
		self.entryType = entryType
		self.diaryStore = diaryStore
		self.eventStore = eventStore
		self.entries = []

		switch entryType {
		case .contactPerson:
			title = AppStrings.ContactDiary.EditEntries.ContactPersons.title

			deleteAllButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.deleteAllButtonTitle
			deleteAllAlertTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteAllAlert.title
			deleteAllAlertMessage = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteAllAlert.message
			deleteAllAlertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteAllAlert.confirmButtonTitle
			deleteAllAlertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteAllAlert.cancelButtonTitle

			deleteOneAlertTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteOneAlert.title
			deleteOneAlertMessage = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteOneAlert.message
			deleteOneAlertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteOneAlert.confirmButtonTitle
			deleteOneAlertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.ContactPersons.DeleteOneAlert.cancelButtonTitle
		case .location:
			title = AppStrings.ContactDiary.EditEntries.Locations.title

			deleteAllButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.deleteAllButtonTitle
			deleteAllAlertTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteAllAlert.title
			deleteAllAlertMessage = AppStrings.ContactDiary.EditEntries.Locations.DeleteAllAlert.message
			deleteAllAlertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteAllAlert.confirmButtonTitle
			deleteAllAlertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteAllAlert.cancelButtonTitle

			deleteOneAlertTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteOneAlert.title
			deleteOneAlertMessage = AppStrings.ContactDiary.EditEntries.Locations.DeleteOneAlert.message
			deleteOneAlertConfirmButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteOneAlert.confirmButtonTitle
			deleteOneAlertCancelButtonTitle = AppStrings.ContactDiary.EditEntries.Locations.DeleteOneAlert.cancelButtonTitle
		}

		diaryStore.diaryDaysPublisher
			.sink { [weak self] days in
				guard let firstDay = days.first else { return }

				self?.entries = firstDay.entries.filter {
					$0.type == entryType
				}
			}.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published private(set) var entries: [DiaryEntry]

	let title: String

	let deleteAllButtonTitle: String
	let deleteAllAlertTitle: String
	let deleteAllAlertMessage: String
	let deleteAllAlertConfirmButtonTitle: String
	let deleteAllAlertCancelButtonTitle: String

	let deleteOneAlertTitle: String
	let deleteOneAlertMessage: String
	let deleteOneAlertConfirmButtonTitle: String
	let deleteOneAlertCancelButtonTitle: String

	func removeEntry(at indexPath: IndexPath) {
		remove(entry: entries[indexPath.row])
	}

	func removeAll() {
		switch entryType {
		case .location:
			diaryStore.removeAllLocations()
		case .contactPerson:
			diaryStore.removeAllContactPersons()
		}
	}

	// MARK: - Private

	private let entryType: DiaryEntryType
	private let diaryStore: DiaryStoringProviding
	private let eventStore: EventStoringProviding
	
	private var subscriptions: [AnyCancellable] = []

	private func remove(entry: DiaryEntry) {
		switch entry {
		case .location(let location):
			// first remove checkin to this location
			if let checkinID = location.visit?.checkinId {
				eventStore.deleteCheckin(id: checkinID)
			}
			// then delete location
			diaryStore.removeLocation(id: location.id)
		case .contactPerson(let contactPerson):
			diaryStore.removeContactPerson(id: contactPerson.id)
		}
	}

}
