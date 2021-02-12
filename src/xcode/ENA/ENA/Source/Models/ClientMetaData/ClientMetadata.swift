////
// 🦠 Corona-Warn-App
//

import UIKit

struct ClientMetadata: Codable {
	var cwaVersion: Version?
	var iosVersion: Version
	var eTag: String?

	enum CodingKeys: String, CodingKey {
		case cwaVersion
		case iosVersion
		case eTag
	}

	init(etag: String?) {
		self.eTag = etag
		
		let iosVersion = ProcessInfo().operatingSystemVersion
		self.iosVersion = Version(
			major: iosVersion.majorVersion,
			minor: iosVersion.minorVersion,
			patch: iosVersion.patchVersion
		)
		
		let appVersionParts = Bundle.main.appVersion.split(separator: ".")
		guard appVersionParts.count == 3,
			  let majorAppVerson = Int(appVersionParts[0]),
			  let minorAppVerson = Int(appVersionParts[1]),
			  let patchAppVersion = Int((appVersionParts[2])) else {
			return
		}
		
		cwaVersion = Version(
			major: majorAppVerson,
			minor: minorAppVerson,
			patch: patchAppVersion
		)
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		cwaVersion = try container.decodeIfPresent(Version.self, forKey: .cwaVersion)
		iosVersion = try container.decode(Version.self, forKey: .iosVersion)
		eTag = try container.decodeIfPresent(String.self, forKey: .eTag)
	}
}

struct Version: Codable, Equatable {
	let major: Int
	let minor: Int
	let patch: Int
	
}
