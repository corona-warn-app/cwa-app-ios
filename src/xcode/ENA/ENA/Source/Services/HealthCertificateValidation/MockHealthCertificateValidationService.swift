////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

struct MockHealthCertificateValidationService: HealthCertificateValidationProviding {

	var onboardedCountriesResult: Result<[Country], HealthCertificateValidationOnboardedCountriesError> = .success(
		[
			Country(countryCode: "DE"),
			Country(countryCode: "IT"),
			Country(countryCode: "ES")
		].compactMap { $0 }
	)

	var validationResult: Result<HealthCertificateValidationReport, HealthCertificateValidationError> = .success(.validationPassed([]))

	func onboardedCountries(
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(onboardedCountriesResult)
		}
	}
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			completion(validationResult)
		}
	}

}
