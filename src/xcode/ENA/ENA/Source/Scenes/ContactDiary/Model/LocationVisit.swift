////
// 🦠 Corona-Warn-App
//

import Foundation

struct LocationVisit: Equatable {

	// MARK: - Init

	internal init(
		id: Int,
		date: String,
		locationId: Int,
		duration: Int = 0,
		circumstances: String = ""
	) {
		self.id = id
		self.date = date
		self.locationId = locationId
		self.duration = duration
		self.circumstances = circumstances
	}


	// MARK: - Internal

	let id: Int
	let date: String
	let locationId: Int

	let duration: Int
	let circumstances: String

}
