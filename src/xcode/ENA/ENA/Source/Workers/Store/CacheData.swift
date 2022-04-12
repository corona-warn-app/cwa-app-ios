//
// 🦠 Corona-Warn-App
//

import Foundation

struct CacheData: Codable {

	// MARK: - Init

	init(
		data: Data,
		eTag: String,
		date: Date
	) {
		self.data = data
		self.eTag = eTag
		self.date = date
	}

	// MARK: - Internal

	let data: Data
	let eTag: String
	let date: Date

}
