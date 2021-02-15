////
// 🦠 Corona-Warn-App
//

import Foundation

struct ClientMetaData: Codable {
	var cwaVersion: String
	var iosVersion: String
	var appConfigETag: String

	enum CodingKeys: String, CodingKey {
		case cwaVersion
		case iosVersion
		case appConfigETag
	}

	init(
		cwaVersion: String,
		iosVersion: String,
		appConfigETag: String
	) {
		self.cwaVersion = cwaVersion
		self.iosVersion = iosVersion
		self.appConfigETag = appConfigETag
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		cwaVersion = try container.decode(String.self, forKey: .cwaVersion)
		iosVersion = try container.decode(String.self, forKey: .iosVersion)
		appConfigETag = try container.decode(String.self, forKey: .appConfigETag)
	}
}
