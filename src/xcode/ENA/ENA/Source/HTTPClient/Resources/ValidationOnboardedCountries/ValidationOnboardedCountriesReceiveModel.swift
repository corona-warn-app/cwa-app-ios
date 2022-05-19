//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ValidationOnboardedCountriesReceiveModel: CBORDecodable {

	// MARK: - Protocol CBORDecoding
	
	static func make(with data: Data) -> Result<ValidationOnboardedCountriesReceiveModel, ModelDecodingError> {

		switch OnboardedCountriesAccess().extractCountryCodes(from: data) {
		case .success(let countryCodes):
			let countries = countryCodes.compactMap {
				Country(withCountryCodeFallback: $0)
			}
			return .success(ValidationOnboardedCountriesReceiveModel(countries: countries))
		case .failure(let error):
			return .failure(.CBOR_DECODING_ONBOARDED_COUNTRIES(error))
		}
	}
	
	// MARK: - Internal

	let countries: [Country]
	
	// MARK: - Private

	private init(countries: [Country] ) {
		self.countries = countries
	}
}
