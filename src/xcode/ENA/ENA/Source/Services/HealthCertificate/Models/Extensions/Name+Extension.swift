////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension Name {

	var fullName: String {
		var givenName = self.givenName
		var familyName = self.familyName

		if givenName == nil || givenName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			givenName = standardizedGivenName
		}

		if familyName == nil || familyName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
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
