////
// 🦠 Corona-Warn-App
//

import UIKit

struct ClientMetadata: Codable {

	// MARK: - Init

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
	
	// MARK: - Protocol Codable
	
	enum CodingKeys: String, CodingKey {
		case cwaVersion
		case iosVersion
		case eTag
	}
	
	// MARK: - Internal
	
	var cwaVersion: Version?
	var iosVersion: Version
	// eTag from the last fetched appConfiguration
	var eTag: String?
}

struct Version: Codable, Equatable {

	// MARK: - Internal

	let major: Int
	let minor: Int
	let patch: Int
	
	var protobuf: SAP_Internal_Ppdd_PPASemanticVersion {
			var protobufVersion = SAP_Internal_Ppdd_PPASemanticVersion()
			protobufVersion.major = UInt32(self.major)
			protobufVersion.minor = UInt32(self.minor)
			protobufVersion.patch = UInt32(self.patch)
			return protobufVersion
	}
}
