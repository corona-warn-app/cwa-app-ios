//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
@testable import ENA

struct MockHealthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding {

	// MARK: - Protocol HealthCertificateValidationOnboardedCountriesProviding

	func onboardedCountries(
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	) {
		completion(onboardedCountriesResult)
	}

	// MARK: - Internal

	var onboardedCountriesResult: Result<[Country], HealthCertificateValidationOnboardedCountriesError> = .success(
		[
			Country(countryCode: "DE"),
			Country(countryCode: "IT"),
			Country(countryCode: "ES")
		].compactMap { $0 }
	)

}
