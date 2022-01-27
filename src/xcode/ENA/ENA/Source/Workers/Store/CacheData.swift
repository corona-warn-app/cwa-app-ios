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

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case data
		case eTag
		case date
	}

	// MARK: - Internal

	let data: Data
	let eTag: String
	let date: Date

}
