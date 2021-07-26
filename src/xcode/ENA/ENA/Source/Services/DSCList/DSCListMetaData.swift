//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

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
		case eTag
		case timestamp
		case dscList
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		eTag = try container.decodeIfPresent(String.self, forKey: .eTag)
		timestamp = try container.decode(Date.self, forKey: .timestamp)

		let dscListData = try container.decode(Data.self, forKey: .dscList)
		dscList = try SAP_Internal_Dgc_DscList(serializedData: dscListData)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encodeIfPresent(eTag, forKey: .eTag)
		try container.encode(timestamp, forKey: .timestamp)

		let dscListData = try dscList.serializedData()
		try container.encode(dscListData, forKey: .dscList)
	}

	// MARK: - Internal

	var eTag: String?
	var timestamp: Date
	var dscList: SAP_Internal_Dgc_DscList
	
	var signingCertificate: [DCCSigningCertificate] {
		return dscList.certificates.map { listItem in
			DCCSigningCertificate(kid: listItem.kid, data: listItem.data)
		}
	}

}
