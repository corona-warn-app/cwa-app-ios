////
// 🦠 Corona-Warn-App
//

import Foundation

struct HealthCertificateValidationOnboardedCountriesCache: Codable {
    
    // MARK: - Internal

	let onboardedCountries: [ValidationCountryCode]
	let lastOnboardedCountriesETag: String
}
