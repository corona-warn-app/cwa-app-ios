////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit
import SwiftyJSON
import class CertLogic.ValidationResult
import class CertLogic.Rule
import class CertLogic.Description

struct MockHealthCertificateValidationService: HealthCertificateValidationProviding {

	var onboardedCountriesResult: Result<[Country], ValidationOnboardedCountriesError> = .success(
		[
			Country(countryCode: "DE"),
			Country(countryCode: "IT"),
			Country(countryCode: "ES")
		].compactMap { $0 }
	)

	var validationResult: Result<HealthCertificateValidationReport, HealthCertificateValidationError> = .success(.validationFailed([validationResult1, validationResult2]))

	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
			completion(onboardedCountriesResult)
		}
	}
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
			completion(validationResult)
		}
	}

}

let validationResult1 = ValidationResult(
	rule: Rule(
		identifier: "TR-001",
		type: "Acceptance",
		version: "",
		schemaVersion: "",
		engine: "",
		engineVersion: "",
		certificateType: "",
		description: [Description(lang: "de", desc: "Art des Tests muss Antigen-Test oder Nukleinsäureamplifikations-Test sein.")],
		validFrom: "",
		validTo: "",
		affectedString: ["v.0.tg"],
		logic: JSON(booleanLiteral: true),
		countryCode: "IT"),
	result: .fail,
	validationErrors: []
)

let validationResult2 = ValidationResult(
	rule: Rule(
		identifier: "TR-002",
		type: "Invalidation",
		version: "",
		schemaVersion: "",
		engine: "",
		engineVersion: "",
		certificateType: "",
		description: [Description(lang: "de", desc: "Ein Antigentest ist maximal 48h gültig.")],
		validFrom: "",
		validTo: "",
		affectedString: ["t.0.ci"],
		logic: JSON(booleanLiteral: true),
		countryCode: "it"),
	result: .open,
	validationErrors: []
)
