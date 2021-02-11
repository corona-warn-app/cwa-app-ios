////
// 🦠 Corona-Warn-App
//

import UIKit

struct ClientMetaData: Codable {
	var cwaVersion: Version?
	var iosVersion: Version
	var eTag: String?

	enum CodingKeys: String, CodingKey {
		case cwaVersion
		case iosVersion
		case eTag
	}

	init(etag: String?) {

		let iosVersion = ProcessInfo().operatingSystemVersion
		self.iosVersion = Version(
			major: iosVersion.majorVersion,
			minor: iosVersion.minorVersion,
			patch: iosVersion.patchVersion
		)
		
		guard let majorAppVerson = Int(AppStrings.Home.appInformationVersion),
			  let minorAppVerson = Int(Bundle.main.appVersion),
			  let patchAppVersion = Int(Bundle.main.appBuildNumber) else {
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

		cwaVersion = try container.decode(Version?.self, forKey: .cwaVersion)
		iosVersion = try container.decode(Version.self, forKey: .iosVersion)
		eTag = try container.decode(String?.self, forKey: .eTag)
	}
}

struct Version: Codable {
	let major: Int
	let minor: Int
	let patch: Int
}
