////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryContactPerson: Equatable {

	struct New: Equatable {

		// MARK: - Internal

		let name: String
		let phoneNumber: String
		let emailAddress: String

	}

	// MARK: - Init

	init(
		id: Int,
		name: String,
		phoneNumber: String = "",
		emailAddress: String = "",
		encounter: ContactPersonEncounter? = nil
	) {
		self.id = id
		self.name = name
		self.phoneNumber = phoneNumber
		self.emailAddress = emailAddress
		self.encounter = encounter
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let phoneNumber: String
	let emailAddress: String
	let encounter: ContactPersonEncounter?

	var isSelected: Bool {
		encounter != nil
	}

}
