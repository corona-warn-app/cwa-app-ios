////
// 🦠 Corona-Warn-App
//

import Foundation

struct HealthCertificateValidationOnboardedCountriesCache: Codable {
    
    // MARK: - Init
    
    init(
        onboardedCountries: [Country],
        lastOnboardedCountriesETag: String
    ) {
        self.onboardedCountries = onboardedCountries
        self.lastOnboardedCountriesETag = lastOnboardedCountriesETag
    }
    
    // MARK: - Overrides
    
    // MARK: - Protocol Codable
    
    enum CodingKeys: String, CodingKey {
        case onboardedCountries
        case lastOnboardedCountriesETag
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        onboardedCountries = try container.decode([Country].self, forKey: .onboardedCountries)
        lastOnboardedCountriesETag = try container.decode(String.self, forKey: .lastOnboardedCountriesETag)
    }
    
    // MARK: - Public
    
    // MARK: - Internal
    
    // MARK: - Private
	
	let onboardedCountries: [Country]?
	let lastOnboardedCountriesETag: String?
}
