////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIImage
import OpenCombine
import class CertLogic.ValidationResult

final class ValidationResultCellModel {

	// MARK: - Init

	init(
		validationResult: ValidationResult
	) {
		self.validationResult = validationResult
	}

	// MARK: - Internal

	var iconImage: UIImage? {
		switch validationResult.result {
		case .fail:
			return UIImage(named: "Icon_CertificateValidation_Failed")
		case .open:
			return UIImage(named: "Icon_CertificateValidation_Open")
		case .passed:
			return nil
		}
	}

	var ruleDescription: String? {
		let localizedDescription = validationResult.rule?.description.first(where: { $0.lang.lowercased() == Locale.current.languageCode?.lowercased() })?.desc
		let englishDescription = validationResult.rule?.description.first(where: { $0.lang.lowercased() == "en" })?.desc
		let firstDescription = validationResult.rule?.description.first?.desc

		return localizedDescription ?? englishDescription ?? firstDescription ?? ruleIdentifier
	}

	var ruleTypeDescription: String? {
		switch validationResult.rule?.ruleType {
		case .acceptence:
			let arrivalCountry = (validationResult.rule?.countryCode).flatMap { Country(countryCode: $0) }

			return String(
				format: AppStrings.HealthCertificate.Validation.Result.acceptanceRule,
				arrivalCountry?.localizedName ?? ""
			)
		case .invalidation:
			return AppStrings.HealthCertificate.Validation.Result.invalidationRule
		case .none:
			return nil
		}
	}

	var keyValuePairs: [(key: String, value: String?)] {
		var keyValuePairs = [(key: String, value: String?)]()

		validationResult.rule?.affectedString.forEach {
			let key: String?

			switch $0 {
			case "v.0.tg":
				key = "Zielkrankheit oder -erreger / Disease or Agent Targeted"
			case "v.0.vp":
				key = "Impfstoff / Vaccine"
			case "v.0.mp":
				key = "Art des Impfstoffs / Vaccine Type"
			case "v.0.ma":
				key = "Hersteller / Manufacturer"
			case "v.0.dn":
				key = "Nummer der Impfung / Number in a series of vaccinations"
			case "v.0.sd":
				key = "Gesamtzahl an Impfdosen / Total number of vaccination doses"
			case "v.0.dt":
				key = "Datum der Impfung / Date of Vaccination (YYYY-MM-DD)"
			case "v.0.co":
				key = "Land der Impfung / Member State of Vaccination"
			case "v.0.is":
				key = "Zertifikataussteller / Certificate Issuer"
			case "v.0.ci":
				key = "Zertifikatkennung / Unique Certificate Identifier"
			case "t.0.tg":
				key = "Zielkrankheit oder -erreger / Disease or Agent Targeted"
			case "t.0.tt":
				key = "Art des Tests / Type of Test"
			case "t.0.nm":
				key = "Produktname / Test Name"
			case "t.0.ma":
				key = "Produktname / Test Name"
			case "t.0.sc":
				key = "Datum und Uhrzeit der Probenahme / Date and Time of Sample Collection (YYYY-MM-DD hh:mm Z)"
			case "t.0.tr":
				key = "Testergebnis / Test Result"
			case "t.0.tc":
				key = "Testzentrum oder -einrichtung / Testing Center or Facility"
			case "t.0.co":
				key = "Land der Testung / Member State of Test"
			case "t.0.is":
				key = "Zertifikataussteller / Certificate Issuer"
			case "t.0.ci":
				key = "Zertifikatkennung / Unique Certificate Identifier"
			case "r.0.tg":
				key = "Zielkrankheit oder -erreger / Disease or Agent Targeted"
			case "r.0.fr":
				key = "Datum des ersten positiven Testergebnisses / Date of first positive test result (YYYY-MM-DD)"
			case "r.0.co":
				key = "Land der Testung / Member State of Test"
			case "r.0.is":
				key = "Zertifikataussteller / Certificate Issuer"
			case "r.0.df":
				key = "Zertifikat gültig ab / Certificate valid from (YYYY-MM-DD)"
			case "r.0.du":
				key = "Zertifikat gültig bis / Certificate valid until (YYYY-MM-DD)"
			case "r.0.ci":
				key = "Zertifikatkennung / Unique Certificate Identifier"
			default:
				key = nil
			}

			if let key = key {
				keyValuePairs.append((key: key, value: "Value"))
			}
		}

		keyValuePairs.append((key: "Regel-ID / Rule ID", value: ruleIdentifier))

		return keyValuePairs
	}

	// MARK: - Private

	private let validationResult: ValidationResult

	private var ruleIdentifier: String? {
		validationResult.rule?.identifier
	}

}
