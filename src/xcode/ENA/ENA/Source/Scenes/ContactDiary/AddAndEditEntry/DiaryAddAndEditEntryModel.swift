////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryAddAndEditEntryModel {

	// MARK: - Init

	init() {
		self.name = ""
		self.phoneNumber = ""
		self.emailAddress = ""
	}

	init(_ location: DiaryLocation) {
		self.name = location.name
		self.phoneNumber = location.phoneNumber
		self.emailAddress = location.emailAddress
	}

	init(_ person: DiaryContactPerson) {
		self.name = person.name
		self.phoneNumber = person.phoneNumber
		self.emailAddress = person.emailAddress
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var name: String
	var phoneNumber: String
	var emailAddress: String

	var isEmpty: Bool {
		return name.isEmpty
	}

	// MARK: - Private

}
