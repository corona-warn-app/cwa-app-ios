//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

class DiaryAddAndEditEntryViewModel {

	// MARK: - Init

	init(
		mode: Mode,
		diaryService: DiaryService,
		dismiss: @escaping () -> Void
	) {
		self.mode = mode
		self.diaryService = diaryService
		self.dismiss = dismiss

		switch mode {
		case .add:
			self.textInput = ""
		case .edit(let entry):
			switch entry {
			case .location(let location):
				self.textInput = location.name
			case .contactPerson(let person):
				self.textInput = person.name
			}
		}
	}

	// MARK: - Internal

	enum Mode {
		case add(DiaryDay, DiaryEntryType)
		case edit(DiaryEntry)
	}

	let mode: Mode
	// is store maybe enougth?
	let diaryService: DiaryService
	let dismiss: () -> Void

	@Published private(set) var textInput: String

	func update(_ text: String?) {
		textInput = text ?? ""
	}

	func save() {
		let store = diaryService.store
		switch mode {
		case .add(let day, let type):
			switch type {
			case .location:
				let id = store.addLocation(name: textInput)
				store.addLocationVisit(locationId: id, date: day.dateString)
			case .contactPerson:
				let id = store.addContactPerson(name: textInput)
				store.addContactPersonEncounter(contactPersonId: id, date: day.dateString)
			}

		case .edit(let entry):
			Log.debug("NYD")
		}

		dismiss()
	}

	var title: String {
		switch mode {
		case .add(_, let entryType):
			return titleText(from: entryType)
		case .edit(let entry):
			return titleText(from: entry.type)
		}
	}

	var placeholderText: String {
		switch mode {
		case .add(_, let entryType):
			return placeholderText(from: entryType)
		case .edit(let entry):
			return placeholderText(from: entry.type)
		}
	}

	// MARK: - Private


	// Unfortunately, Swift does not currently have KeyPath support for static let,
	// so we need to go that way
	private func titleText(from type: DiaryEntryType) -> String {
		switch type {
		case .location:
			return AppStrings.ContactDiary.AddEditEntry.location.title
		case .contactPerson:
			return AppStrings.ContactDiary.AddEditEntry.person.title
		}
	}

	// Unfortunately, Swift does not currently have KeyPath support for static let,
	// so we need to go that way
	private func placeholderText(from type: DiaryEntryType) -> String {
		switch type {
		case .location:
			return AppStrings.ContactDiary.AddEditEntry.location.placeholder
		case .contactPerson:
			return AppStrings.ContactDiary.AddEditEntry.person.placeholder
		}
	}

}
