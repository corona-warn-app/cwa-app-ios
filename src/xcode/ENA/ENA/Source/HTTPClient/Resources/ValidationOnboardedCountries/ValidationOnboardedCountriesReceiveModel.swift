//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ValidationOnboardedCountriesReceiveModel: CBORDecoding {
	
	// MARK: - Protocol CBORDecoding

	static func decode(_ data: Data) -> Result<ValidationOnboardedCountriesReceiveModel, ModelDecodingError> {
		switch OnboardedCountriesAccess().extractCountryCodes(from: data) {
		case .success(let countryCodes):
			let countries = countryCodes.compactMap {
				Country(withCountryCodeFallback: $0)
			}
			return Result.success(ValidationOnboardedCountriesReceiveModel(countries: countries))
		case .failure(let error):
			return Result.failure(.CBOR_DECODING_ONBOARDED_COUNTRIES(error))
		}
	}
	
	// MARK: - Internal

	let countries: [Country]
	
	// MARK: - Private

	private init(countries: [Country] ) {
		self.countries = countries
	}
}
