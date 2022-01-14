//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct ValidationOnboardedCountriesModel: CBORDecoding {
	init(decodeCBOR: Data) throws {
		
		let extractOnboardedCountryCodesResult = OnboardedCountriesAccess().extractCountryCodes(from: decodeCBOR)
		
		switch extractOnboardedCountryCodesResult {
		case let .success(countryCodes):
			self.countries = countryCodes.compactMap {
				Country(withCountryCodeFallback: $0)
			}

		case let .failure(error):
			throw error
		}
	}
	let countries: [Country]
}
