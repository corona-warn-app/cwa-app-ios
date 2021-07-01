////
// 🦠 Corona-Warn-App
//

import Foundation

enum HealthCertificateValidationError: Error {
	
	// MARK: - Internal
	
	case TECHNICAL_VALIDATION_FAILED (HealthCertificateValidationReport)
	case ACCEPTANCE_RULE_CLIENT_ERROR (HealthCertificateValidationReport)
	case ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING (HealthCertificateValidationReport)
	case ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID (HealthCertificateValidationReport)
	case ACCEPTANCE_RULE_JSON_EXTRACTION_FAILED (HealthCertificateValidationReport)
	case ACCEPTANCE_RULE_SERVER_ERROR (HealthCertificateValidationReport)
	case INVALIDATION_RULE_CLIENT_ERROR (HealthCertificateValidationReport)
	case INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING (HealthCertificateValidationReport)
	case INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID (HealthCertificateValidationReport)
	case INVALIDATION_RULE_JSON_EXTRACTION_FAILED (HealthCertificateValidationReport)
	case INVALIDATION_RULE_SERVER_ERROR (HealthCertificateValidationReport)
	case NO_NETWORK
	case VALUE_SET_SERVER_ERROR

}
