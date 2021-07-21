//
// 🦠 Corona-Warn-App
//

import Foundation

struct DSCListMetaData: Codable {

	// MARK: - Init

	init(
		eTag: String?,
		timestamp: Date,
		dscList: SAP_Internal_Dgc_DscList
	) {
		self.eTag = eTag
		self.timestamp = timestamp
		self.dscList = dscList
	}

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case lastETag
		case lastFetch
		case dscList
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		eTag = try container.decodeIfPresent(String.self, forKey: .lastETag)
		timestamp = try container.decode(Date.self, forKey: .lastFetch)

		let dscListData = try container.decode(Data.self, forKey: .dscList)
		dscList = try SAP_Internal_Dgc_DscList(serializedData: dscListData)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encodeIfPresent(eTag, forKey: .lastETag)
		try container.encode(timestamp, forKey: .lastFetch)

		let dscListResponse = try dscList.serializedData()
		try container.encode(dscListResponse, forKey: .dscList)
	}

	// MARK: - Internal

	var eTag: String?
	var timestamp: Date
	var dscList: SAP_Internal_Dgc_DscList

}
