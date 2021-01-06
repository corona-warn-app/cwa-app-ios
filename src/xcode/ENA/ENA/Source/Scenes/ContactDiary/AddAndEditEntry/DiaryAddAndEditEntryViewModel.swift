//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class DiaryAddAndEditEntryViewModel {

	// MARK: - Init

	init(
		mode: Mode,
		store: DiaryStoring
	) {
		self.mode = mode
		self.store = store

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

	@OpenCombine.Published private(set) var textInput: String

	func update(_ text: String?) {
		textInput = text ?? ""
	}

	func reset() {
		textInput = ""
	}

	func save() {
		switch mode {
		case let .add(day, type):
			switch type {
			case .location:
				let result = store.addLocation(name: textInput)

				if case let .success(id) = result {
					store.addLocationVisit(locationId: id, date: day.dateString)
				}
			case .contactPerson:
				let result = store.addContactPerson(name: textInput)

				if case let .success(id) = result {
					store.addContactPersonEncounter(contactPersonId: id, date: day.dateString)
				}
			}

		case .edit(let entry):
			switch entry {
			case .location(let location):
				let id = location.id
				store.updateLocation(id: id, name: textInput)
			case .contactPerson(let person):
				let id = person.id
				store.updateContactPerson(id: id, name: textInput)
			}
		}
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

	private let mode: Mode
	private let store: DiaryStoring

	// Unfortunately, Swift currently does not have KeyPath support for static let,
	// so we need to go that way
	private func titleText(from type: DiaryEntryType) -> String {
		switch type {
		case .location:
			return AppStrings.ContactDiary.AddEditEntry.location.title
		case .contactPerson:
			return AppStrings.ContactDiary.AddEditEntry.person.title
		}
	}

	// Unfortunately, Swift currently does not have KeyPath support for static let,
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
