//
// 🦠 Corona-Warn-App
//

import Foundation

struct CacheData: Codable {

	// MARK: - Init

	init(
		data: Data,
		eTag: String,
		serverDate: Date?,
		clientDate: Date
	) {
		self.data = data
		self.eTag = eTag
		self.serverDate = serverDate
		self.clientDate = clientDate
	}

	// MARK: - Protocol Codable

	/// in previous versions the server date got stored in the property 'date'
	/// to make old data readable we reuse that key and map it to serverdate
	enum CodingKeys: String, CodingKey {
		case data
		case eTag
		case serverDate = "date"
		case clientDate
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		data = try container.decode(Data.self, forKey: .data)
		eTag = try container.decode(String.self, forKey: .eTag)

		let oldDate = try container.decode(Date.self, forKey: .serverDate)
		serverDate = oldDate
		let cDate = try container.decodeIfPresent(Date.self, forKey: .clientDate)
		clientDate = cDate ?? oldDate
	}

	// MARK: - Internal

	let data: Data
	let eTag: String
	let serverDate: Date?
	let clientDate: Date

}
