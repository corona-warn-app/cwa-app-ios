////
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertificateValidationError: LocalizedError {
	
	// MARK: - Internal
	
	case TECHNICAL_VALIDATION_FAILED
	case ACCEPTANCE_RULE_CLIENT_ERROR
	case ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING
	case ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case ACCEPTANCE_RULE_JSON_EXTRACTION_FAILED
	case ACCEPTANCE_RULE_SERVER_ERROR
	case INVALIDATION_RULE_CLIENT_ERROR
	case INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING
	case INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case INVALIDATION_RULE_JSON_EXTRACTION_FAILED
	case INVALIDATION_RULE_SERVER_ERROR
	case NO_NETWORK
	case VALUE_SET_SERVER_ERROR

	var errorDescription: String? {
		switch self {
		case .TECHNICAL_VALIDATION_FAILED:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (TECHNICAL_VALIDATION_FAILED)"
		case .ACCEPTANCE_RULE_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_CLIENT_ERROR)"
		case .ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING)"
		case .ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .ACCEPTANCE_RULE_JSON_EXTRACTION_FAILED:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_EXTRACTION_FAILED)"
		case .ACCEPTANCE_RULE_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_SERVER_ERROR)"
		case .INVALIDATION_RULE_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_CLIENT_ERROR)"
		case .INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING)"
		case .INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .INVALIDATION_RULE_JSON_EXTRACTION_FAILED:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_EXTRACTION_FAILED)"
		case .INVALIDATION_RULE_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_SERVER_ERROR)"
		case .NO_NETWORK:
			return "\(AppStrings.HealthCertificate.ValidationError.noNetwork) (NO_NETWORK)"
		case .VALUE_SET_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (VALUE_SET_SERVER_ERROR)"
		}
	}

}
