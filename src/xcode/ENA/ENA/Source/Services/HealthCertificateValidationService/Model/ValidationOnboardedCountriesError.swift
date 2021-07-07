////
// 🦠 Corona-Warn-App
//

import Foundation

enum ValidationOnboardedCountriesError: LocalizedError {

	// MARK: - Internal
	
	case ONBOARDED_COUNTRIES_CLIENT_ERROR
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID
	case ONBOARDED_COUNTRIES_JSON_DECODING_FAILED
	case ONBOARDED_COUNTRIES_SERVER_ERROR
	case ONBOARDED_COUNTRIES_MISSING_CACHE
	case ONBOARDED_COUNTRIES_NO_NETWORK

	var errorDescription: String? {
		switch self {
		case .ONBOARDED_COUNTRIES_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_CLIENT_ERROR)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .ONBOARDED_COUNTRIES_JSON_DECODING_FAILED:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_JSON_EXTRACTION_FAILED)"
		case .ONBOARDED_COUNTRIES_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_SERVER_ERROR)"
		case .ONBOARDED_COUNTRIES_MISSING_CACHE:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (ONBOARDED_COUNTRIES_MISSING_CACHE)"
		case .ONBOARDED_COUNTRIES_NO_NETWORK:
			return "\(AppStrings.HealthCertificate.Validation.Error.noNetwork) (NO_NETWORK)"
		}
	}

}
