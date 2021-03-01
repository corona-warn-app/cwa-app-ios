////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryAddAndEditEntryModel {

	// MARK: - Init

	init(
		location: DiaryLocation? = nil,
		person: DiaryContactPerson? = nil,
		type: DiaryEntryType
	) {
		switch type {
		case .contactPerson:
			self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.name
			self.phoneNumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.phoneNumber
			self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.email

		case .location:
			self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.name
			self.phoneNumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.phoneNumber
			self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.email
		}
		self.name = location?.name ?? person?.name ?? ""
		self.phoneNumber = location?.phoneNumber ?? person?.phoneNumber ?? ""
		self.emailAddress = location?.emailAddress ?? person?.emailAddress ?? ""
	}

	init(_ type: DiaryEntryType) {
		self.init(type: type)
	}

	init(_ location: DiaryLocation) {
		self.init(location: location, type: .location)
	}

	init(_ person: DiaryContactPerson) {
		self.init(person: person, type: .contactPerson)
	}

	// MARK: - Internal

	let namePlaceholder: String
	let phoneNumberPlaceholder: String
	let emailAddressPlaceholder: String

	var name: String
	var phoneNumber: String
	var emailAddress: String

	var isEmpty: Bool {
		return name.isEmpty
	}

	// MARK: - Private

}
