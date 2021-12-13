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

	var reversedFullNameWithoutFallback: String {
		return [familyName, givenName].formatted(separator: ", ")
	}

	var standardizedName: String {
		return [standardizedGivenName, standardizedFamilyName].formatted()
	}
	
	var groupingStandardizedName: String {
		return trimmedStandardizedName
			.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
			.replacingOccurrences(of: "<+", with: "<", options: .regularExpression)
			.trimmingCharacters(in: .whitespaces)
	}
	
	var reversedStandardizedName: String {
		var standardizedFamilyName = self.standardizedFamilyName
		standardizedFamilyName += "<<"
		return [standardizedFamilyName, standardizedGivenName].formatted(separator: "")
	}

	private var trimmedStandardizedName: String {
		return [
			standardizedGivenName?.trimmingCharacters(in: CharacterSet(charactersIn: "<")),
			standardizedFamilyName.trimmingCharacters(in: CharacterSet(charactersIn: "<"))
		].formatted()
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
	
	func formatted(separator: String = " ") -> String {
		return self
			.compactMap { $0 }
			.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
			.joined(separator: separator)
			
	}
}
