////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryContactPerson: Equatable {

	struct New: Equatable {

		// MARK: - Internal

		let name: String

	}

	// MARK: - Init

	init(id: Int, name: String, encounterId: Int? = nil) {
		self.id = id
		self.name = name
		self.encounterId = encounterId
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let encounterId: Int?

	var isSelected: Bool {
		encounterId != nil
	}

}
