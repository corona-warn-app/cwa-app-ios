////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateValidationOnboardedCountriesError: LocalizedError {

	// MARK: - Internal
	
	case ONBOARDED_COUNTRIES_CLIENT_ERROR
	case ONBOARDED_COUNTRIES_DECODING_ERROR(RuleValidationError)
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING
	case ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID
	case ONBOARDED_COUNTRIES_SERVER_ERROR
	case ONBOARDED_COUNTRIES_MISSING_CACHE
	case ONBOARDED_COUNTRIES_NO_NETWORK

	var errorDescription: String? {
		switch self {
		case .ONBOARDED_COUNTRIES_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_CLIENT_ERROR)"
		case let .ONBOARDED_COUNTRIES_DECODING_ERROR(error):
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_DECODING_ERROR - \(error)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING)"
		case .ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .ONBOARDED_COUNTRIES_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_SERVER_ERROR)"
		case .ONBOARDED_COUNTRIES_MISSING_CACHE:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ONBOARDED_COUNTRIES_MISSING_CACHE)"
		case .ONBOARDED_COUNTRIES_NO_NETWORK:
			return "\(AppStrings.HealthCertificate.ValidationError.noNetwork) (NO_NETWORK)"
		}
	}
}

extension HealthCertificateValidationOnboardedCountriesError: Equatable {
	static func == (lhs: HealthCertificateValidationOnboardedCountriesError, rhs: HealthCertificateValidationOnboardedCountriesError) -> Bool {
		switch (lhs, rhs) {
		case let (.ONBOARDED_COUNTRIES_DECODING_ERROR(lhsRuleValidationError), .ONBOARDED_COUNTRIES_DECODING_ERROR(rhsRuleValidationError)):
			return lhsRuleValidationError == rhsRuleValidationError
		default:
			return lhs.localizedDescription == rhs.localizedDescription
		}
	}
}
