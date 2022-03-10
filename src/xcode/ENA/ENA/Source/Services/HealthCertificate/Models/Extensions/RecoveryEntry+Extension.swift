////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

extension RecoveryEntry {

	var localCertificateValidityStartDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: certificateValidFrom)
	}

	var localCertificateValidityEndDate: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: certificateValidUntil)
	}

	var localDateOfFirstPositiveNAAResult: Date? {
		return ISO8601DateFormatter.justLocalDateFormatter.date(from: dateOfFirstPositiveNAAResult)
	}

	func title(for keyPath: PartialKeyPath<RecoveryEntry>) -> String? {
		switch keyPath {
		case \RecoveryEntry.diseaseOrAgentTargeted:
			return "Genesen von / Recovered from"
		case \RecoveryEntry.dateOfFirstPositiveNAAResult:
			return "Datum des ersten positiven Testergebnisses / Date of first positive test result (YYYY-MM-DD)"
		case \RecoveryEntry.countryOfTest:
			return "Land der Testung / Member State of Test"
		case \RecoveryEntry.certificateIssuer:
			return "Zertifikataussteller / Certificate Issuer"
		case \RecoveryEntry.certificateValidFrom:
			return "Zertifikat gültig ab / Certificate valid from (YYYY-MM-DD)"
		case \RecoveryEntry.certificateValidUntil:
			return "Zertifikat gültig bis / Certificate valid until (YYYY-MM-DD)"
		case \RecoveryEntry.uniqueCertificateIdentifier:
			return "Zertifikatkennung / Unique Certificate Identifier"
		default:
			return nil
		}
	}

	func formattedValue(for keyPath: PartialKeyPath<RecoveryEntry>, valueSets: SAP_Internal_Dgc_ValueSets?) -> String? {
		switch keyPath {
		case \RecoveryEntry.diseaseOrAgentTargeted:
			return valueSets?
				.valueSet(for: .diseaseOrAgentTargeted)?
				.displayText(forKey: diseaseOrAgentTargeted) ?? diseaseOrAgentTargeted
		case \RecoveryEntry.dateOfFirstPositiveNAAResult:
			return DCCDateStringFormatter.formattedString(from: dateOfFirstPositiveNAAResult)
		case \RecoveryEntry.countryOfTest:
			return Country(countryCode: countryOfTest)?.localizedName ?? countryOfTest
		case \RecoveryEntry.certificateIssuer:
			return certificateIssuer
		case \RecoveryEntry.certificateValidFrom:
			return certificateValidFrom
		case \RecoveryEntry.certificateValidUntil:
			return certificateValidUntil
		case \RecoveryEntry.uniqueCertificateIdentifier:
			return uniqueCertificateIdentifier
		default:
			return nil
		}
	}

}
