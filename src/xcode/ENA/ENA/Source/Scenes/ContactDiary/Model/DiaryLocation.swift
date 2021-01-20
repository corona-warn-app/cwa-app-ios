////
// 🦠 Corona-Warn-App
//

import Foundation

struct DiaryLocation: Equatable {

	struct New: Equatable {

		// MARK: - Internal

		let name: String

	}

	// MARK: - Init

	init(id: Int, name: String, visitId: Int? = nil) {
		self.id = id
		self.name = name
		self.visitId = visitId
	}

	// MARK: - Internal

	let id: Int
	let name: String
	let visitId: Int?

	var isSelected: Bool {
		visitId != nil
	}

}
