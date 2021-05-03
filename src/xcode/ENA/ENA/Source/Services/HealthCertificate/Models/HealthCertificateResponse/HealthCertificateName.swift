////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

struct HealthCertificateName: Codable, Equatable {

	// MARK: - Protocol Codable

	enum CodingKeys: String, CodingKey {
		case familyName = "fn"
		case givenName = "gn"
		case standardizedFamilyName = "fnt"
		case standardizedGivenName = "gnt"
	}

	// MARK: - Internal

	let familyName: String?
	let givenName: String?
	let standardizedFamilyName: String
	let standardizedGivenName: String?

	var fullName: String {
		var givenName = self.givenName
		var familyName = self.familyName

		if givenName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			givenName = standardizedGivenName
		}

		if familyName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			familyName = standardizedFamilyName
		}

		return [givenName, familyName]
			.compactMap { $0 }
			.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
			.joined(separator: " ")
	}

	var standardizedName: String {
		[standardizedGivenName, standardizedFamilyName]
			.compactMap { $0 }
			.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
			.joined(separator: " ")
	}

}
