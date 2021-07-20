//
// 🦠 Corona-Warn-App
//

import Foundation

struct DSCListMetaData: Codable {

	// MARK: - Init

	init(
		lastETag: String,
		lastFetch: Date,
		dscListResponse: SAP_Internal_Dgc_DscList
	) {
		self.lastETag = lastETag
		self.lastFetch = lastFetch
		self.dscListResponse = dscListResponse
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case lastETag
		case lastFetch
		case dscListResponse
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		lastETag = try container.decode(String.self, forKey: .lastETag)
		lastFetch = try container.decode(Date.self, forKey: .lastFetch)

		let dscListData = try container.decode(Data.self, forKey: .dscListResponse)
		dscListResponse = try SAP_Internal_Dgc_DscList(serializedData: dscListData)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(lastETag, forKey: .lastETag)
		try container.encode(lastFetch, forKey: .lastFetch)

		let dscListResponse = try dscListResponse.serializedData()
		try container.encode(dscListResponse, forKey: .dscListResponse)
	}

	// MARK: - Internal

	var lastETag: String
	var lastFetch: Date
	var dscListResponse: SAP_Internal_Dgc_DscList

}
