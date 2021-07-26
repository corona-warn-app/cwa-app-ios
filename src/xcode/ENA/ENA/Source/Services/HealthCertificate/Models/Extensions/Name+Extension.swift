////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension Name {

	var fullName: String {
		return [resolvedGivenName, resolvedFamilyName].formatted()
	}
	
	var reversedFullName: String {
		var resolvedFamilyName = self.resolvedFamilyName ?? ""
		resolvedFamilyName += ","
		return [resolvedFamilyName, resolvedGivenName].formatted()
	}

	var standardizedName: String {
		return [standardizedGivenName, standardizedFamilyName].formatted()
	}

	private var resolvedGivenName: String? {
		var givenName = self.givenName
		if givenName == nil || givenName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			givenName = standardizedGivenName
		}
		return givenName
	}
	
	private var resolvedFamilyName: String? {
		var familyName = self.familyName
		if familyName == nil || familyName?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
			familyName = standardizedFamilyName
		}
		return familyName
	}
}

fileprivate extension Sequence where Element == String? {
	
	func formatted() -> String {
		return self
			.compactMap { $0 }
			.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
			.joined(separator: " ")
			
	}
}
