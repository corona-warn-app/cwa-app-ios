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
		case .add(_, let entryType):
			self.entryModel = DiaryAddAndEditEntryModel(entryType)

		case .edit(let entry):
			switch entry {
			case .location(let location):
				self.entryModel = DiaryAddAndEditEntryModel(location)

			case .contactPerson(let person):
				self.entryModel = DiaryAddAndEditEntryModel(person)
			}
		}
	}

	// MARK: - Internal

	enum Mode {
		case add(DiaryDay, DiaryEntryType)
		case edit(DiaryEntry)
	}

	@OpenCombine.Published private(set) var entryModel: DiaryAddAndEditEntryModel

	func update(_ text: String?, keyPath: WritableKeyPath<DiaryAddAndEditEntryModel, String>) {
		entryModel[keyPath: keyPath] = text ?? ""
	}

	func reset(keyPath: WritableKeyPath<DiaryAddAndEditEntryModel, String>) {
		entryModel[keyPath: keyPath] = ""
	}

	func save() {
		switch mode {
		case let .add(day, type):
			switch type {
			case .location:
				let result = store.addLocation(
					name: entryModel.name,
					phoneNumber: entryModel.phoneNumber,
					emailAddress: entryModel.emailAddress,
					traceLocationId: nil
				)

				if case let .success(id) = result {
					store.addLocationVisit(locationId: id, date: day.dateString)
				}
			case .contactPerson:
				let result = store.addContactPerson(name: entryModel.name, phoneNumber: entryModel.phoneNumber, emailAddress: entryModel.emailAddress)

				if case let .success(id) = result {
					store.addContactPersonEncounter(contactPersonId: id, date: day.dateString)
				}
			}

		case .edit(let entry):
			switch entry {
			case .location(let location):
				store.updateLocation(id: location.id, name: entryModel.name, phoneNumber: entryModel.phoneNumber, emailAddress: entryModel.emailAddress)
			case .contactPerson(let person):
				store.updateContactPerson(id: person.id, name: entryModel.name, phoneNumber: entryModel.phoneNumber, emailAddress: entryModel.emailAddress)
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

	var namePlaceholder: String {
		return entryModel.namePlaceholder
	}

	var phoneNumberPlaceholder: String {
		return entryModel.phoneNumberPlaceholder
	}

	var emailAddressPlaceholder: String {
		return entryModel.emailAddressPlaceholder
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

}
