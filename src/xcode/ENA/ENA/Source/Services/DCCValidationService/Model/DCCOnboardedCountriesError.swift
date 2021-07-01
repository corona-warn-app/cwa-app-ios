////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCOnboardedCountriesError: Error {
	
	// MARK: - Internal
	
	case ONBOARDED_COUNTRIES_CLIENT_ERROR
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID
	case ONBOARDED_COUNTRIES_JSON_EXTRACTION_FAILED
	case ONBOARDED_COUNTRIES_JSON_DECODING_FAILED
	case ONBOARDED_COUNTRIES_SERVER_ERROR
	case ONBOARDED_COUNTRIES_MISSING_CACHE
	case NO_NETWORK
}
