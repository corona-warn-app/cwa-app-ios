////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateValidationError: LocalizedError {
	
	// MARK: - Internal
	
	case TECHNICAL_VALIDATION_FAILED
	case ACCEPTANCE_RULE_DECODING_ERROR(RuleValidationError)
	case ACCEPTANCE_RULE_CLIENT_ERROR
	case ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR
	case ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING
	case ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case ACCEPTANCE_RULE_MISSING_CACHE
	case ACCEPTANCE_RULE_SERVER_ERROR
	case INVALIDATION_RULE_DECODING_ERROR(RuleValidationError)
	case INVALIDATION_RULE_CLIENT_ERROR
	case INVALIDATION_RULE_JSON_ARCHIVE_ETAG_ERROR
	case INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING
	case INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case INVALIDATION_RULE_MISSING_CACHE
	case INVALIDATION_RULE_SERVER_ERROR
	case NO_NETWORK
	case VALUE_SET_SERVER_ERROR
	case VALUE_SET_CLIENT_ERROR
	case RULES_VALIDATION_ERROR(RuleValidationError)

	var errorDescription: String? {
		switch self {
		case .TECHNICAL_VALIDATION_FAILED:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (TECHNICAL_VALIDATION_FAILED)"
		case let .ACCEPTANCE_RULE_DECODING_ERROR(error):
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_DECODING_ERROR - \(error)"
		case .ACCEPTANCE_RULE_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_CLIENT_ERROR)"
		case .ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR)"
		case .ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING)"
		case .ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .ACCEPTANCE_RULE_MISSING_CACHE:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_MISSING_CACHE)"
		case .ACCEPTANCE_RULE_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (ACCEPTANCE_RULE_SERVER_ERROR)"
		case let .INVALIDATION_RULE_DECODING_ERROR(error):
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_DECODING_ERROR - \(error)"
		case .INVALIDATION_RULE_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_CLIENT_ERROR)"
		case .INVALIDATION_RULE_JSON_ARCHIVE_ETAG_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_ARCHIVE_ETAG_ERROR)"
		case .INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING)"
		case .INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case .INVALIDATION_RULE_MISSING_CACHE:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_MISSING_CACHE)"
		case .INVALIDATION_RULE_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (INVALIDATION_RULE_SERVER_ERROR)"
		case .NO_NETWORK:
			return "\(AppStrings.HealthCertificate.ValidationError.noNetwork) (NO_NETWORK)"
		case .VALUE_SET_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (VALUE_SET_SERVER_ERROR)"
		case .VALUE_SET_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (VALUE_SET_CLIENT_ERROR)"
		case let .RULES_VALIDATION_ERROR(error):
			return "\(AppStrings.HealthCertificate.ValidationError.tryAgain) (RULES_VALIDATION_ERROR - \(error)"
		}
	}
}

extension HealthCertificateValidationError: Equatable {
	static func == (lhs: HealthCertificateValidationError, rhs: HealthCertificateValidationError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
