////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension Name {

	// MARK: - Internal

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
	
	var givenNameGroupingComponents: [String] {
		return standardizedGivenName?.groupingComponents() ?? []
	}
	
	var familyNameGroupingComponents: [String] {
		return standardizedFamilyName.groupingComponents()
	}
	
	var reversedStandardizedName: String {
		var standardizedFamilyName = self.standardizedFamilyName
		standardizedFamilyName += "<<"
		return [standardizedFamilyName, standardizedGivenName].formatted(separator: "")
	}

	// MARK: - Private

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

fileprivate extension String {
	
	func groupingComponents() -> [String] {
		let components: [String] =
		// the string shall be trimmed for leading and trailing whitespace
		self.trimmingCharacters(in: .whitespaces)
		// the string shall be trimmed for leading and trailing `<`
			.trimmingCharacters(in: CharacterSet(charactersIn: "<"))
		// any whitespace in the string shall be replaced by `<`
			.replacingOccurrences(of: "\\s+", with: "<", options: .regularExpression)
		// dots `.` and dashes `-` shall be replaced by `<`
			.replacingOccurrences(of: "-", with: "<")
			.replacingOccurrences(of: ".", with: "<")
		// any occurence of more than one `<` shall be replaced by a single `<`
			.replacingOccurrences(of: "<+", with: "<", options: .regularExpression)
		// the string shall be converted to upper-case
			.uppercased()
		// German umlauts `Ä/ä`, `Ö/ö`, `Ü/ü` shall be replaced by `AE`, `OE`, `UE`
			.replacingOccurrences(of: "Ä", with: "AE")
			.replacingOccurrences(of: "Ö", with: "OE")
			.replacingOccurrences(of: "Ü", with: "UE")
		// German `ß` shall be replaced by `SS`
			.replacingOccurrences(of: "ß", with: "SS")
		// the string shall be split by `<` to dermine the components
			.split(separator: "<")
			.map { String($0) }
		// the following components shall be filtered out: `DR`
			.filter { $0 != "DR" }
		return components
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
