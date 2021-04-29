////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificateName: Codable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case familyName = "fn"
		case givenName = "gn"
		case standardizedFamilyName = "fnt"
		case standardizedGivenName = "gnt"
	}

	// MARK: - Internal

	let familyName: String
	let givenName: String
	let standardizedFamilyName: String
	let standardizedGivenName: String

}
