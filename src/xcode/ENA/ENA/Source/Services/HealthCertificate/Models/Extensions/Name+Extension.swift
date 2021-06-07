////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension Name {

	var fullName: String {
		
		let givenName: String?
		let familyName: String
		
		if let value = self.givenName?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
			givenName = value
		} else {
			givenName = readableStandardizedGivenName
		}
		
		if let value = self.familyName?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
			familyName = value
		} else {
			familyName = readableStandardizedFamilyName
		}
		
		let formatter = PersonNameComponentsFormatter()
		formatter.style = .long

		var nameComponents = PersonNameComponents()
		nameComponents.givenName = givenName
		nameComponents.familyName = familyName

		return formatter.string(from: nameComponents)
	}

	var standardizedName: String {
		
		let formatter = PersonNameComponentsFormatter()
		formatter.style = .long

		var nameComponents = PersonNameComponents()
		nameComponents.givenName = readableStandardizedGivenName
		nameComponents.familyName = readableStandardizedFamilyName
		
		return formatter.string(from: nameComponents)
	}

	private var readableStandardizedGivenName: String? {
		return standardizedGivenName?.components(separatedBy: "<").joined(separator: " ")
	}
	
	private var readableStandardizedFamilyName: String {
		return standardizedFamilyName.components(separatedBy: "<").joined(separator: " ")
	}
}
