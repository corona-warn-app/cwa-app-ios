////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct MockDCCValidationService: DCCValidationProviding {

	var onboardedCountriesResult: Result<[Country], DCCOnboardedCountriesError> = .success(
		[
			Country(countryCode: "DE"),
			Country(countryCode: "IT"),
			Country(countryCode: "ES")
		].compactMap { $0 }
	)

	var validateDCCResult: Result<DCCValidationReport, DCCValidationError> = .success(
		DCCValidationReport(expirationCheck: true, jsonSchemaCheck: true, acceptanceRuleValidation: nil, invalidationRuleValidation: nil)
	)

	func onboardedCountries(
		completion: @escaping (Result<[Country], DCCOnboardedCountriesError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(onboardedCountriesResult)
		}
	}
	
	func validateDcc(
		dcc: DigitalCovidCertificate,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Date,
		cborWebToken: CBORWebTokenHeader,
		completion: @escaping (Result<DCCValidationReport, DCCValidationError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(validateDCCResult)
		}
	}

}
