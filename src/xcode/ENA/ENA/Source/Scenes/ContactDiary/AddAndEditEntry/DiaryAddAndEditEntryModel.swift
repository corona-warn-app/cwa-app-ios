////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryAddAndEditEntryModel {

	// MARK: - Init

	init(_ type: DiaryEntryType) {
		switch type {
		case .contactPerson:
			self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.name
			self.phonenumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.phonenumber
			self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.email

		case .location:
			self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.name
			self.phonenumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.phonenumber
			self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.email
		}

		self.name = ""
		self.phoneNumber = ""
		self.emailAddress = ""
	}

	init(_ location: DiaryLocation) {
		self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.name
		self.phonenumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.phonenumber
		self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.location.placeholders.email

		self.name = location.name
		self.phoneNumber = location.phoneNumber
		self.emailAddress = location.emailAddress
	}

	init(_ person: DiaryContactPerson) {
		self.namePlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.name
		self.phonenumberPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.phonenumber
		self.emailAddressPlaceholder = AppStrings.ContactDiary.AddEditEntry.person.placeholders.email

		self.name = person.name
		self.phoneNumber = person.phoneNumber
		self.emailAddress = person.emailAddress
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	let namePlaceholder: String
	let phonenumberPlaceholder: String
	let emailAddressPlaceholder: String

	var name: String
	var phoneNumber: String
	var emailAddress: String

	var isEmpty: Bool {
		return name.isEmpty
	}

	// MARK: - Private

}
