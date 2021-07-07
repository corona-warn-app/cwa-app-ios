////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateValidationError: Error {
	
	// MARK: - Internal
	
	case TECHNICAL_VALIDATION_FAILED
	case ACCEPTANCE_RULE_VALIDATION_ERROR(RuleValidationError)
	case ACCEPTANCE_RULE_CLIENT_ERROR
	case ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING
	case ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case ACCEPTANCE_RULE_JSON_DECODING_FAILED
	case ACCEPTANCE_RULE_MISSING_CACHE
	case ACCEPTANCE_RULE_SERVER_ERROR
	case INVALIDATION_RULE_VALIDATION_ERROR(RuleValidationError)
	case INVALIDATION_RULE_CLIENT_ERROR
	case INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING
	case INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
	case INVALIDATION_RULE_JSON_DECODING_FAILED
	case INVALIDATION_RULE_MISSING_CACHE
	case INVALIDATION_RULE_SERVER_ERROR
	case NO_NETWORK
	case VALUE_SET_SERVER_ERROR

}

extension HealthCertificateValidationError: Equatable {
	static func == (lhs: HealthCertificateValidationError, rhs: HealthCertificateValidationError) -> Bool {
		lhs.localizedDescription == rhs.localizedDescription
	}
}
