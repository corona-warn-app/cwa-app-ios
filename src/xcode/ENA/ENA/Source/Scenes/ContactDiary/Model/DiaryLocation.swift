////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryLocation: Equatable {

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
		visit: LocationVisit? = nil
	) {
		self.id = id
		self.name = name
		self.phoneNumber = phoneNumber
		self.emailAddress = emailAddress
		self.visit = visit
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let phoneNumber: String
	let emailAddress: String
	let visit: LocationVisit?

	var isSelected: Bool {
		visit != nil
	}

}
