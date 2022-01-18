//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum BoosterNotificationServiceError: LocalizedError {
	case CERTIFICATE_VALIDATION_ERROR(HealthCertificateValidationError)
	case BOOSTER_VALIDATION_ERROR(BoosterNotificationRuleValidationError)

	#if !RELEASE
	// ONLY USED FOR TESTING IN THE DEV MENU
	var errorDescription: String? {
		switch self {
		case .BOOSTER_VALIDATION_ERROR(let boosterError):
			switch boosterError {
			case .CBOR_DECODING_FAILED:
				return "CBOR_DECODING_FAILED"
			case .JSON_ENCODING_FAILED:
				return "JSON_ENCODING_FAILED"
			case .JSON_VALIDATION_RULE_SCHEMA_NOTFOUND:
				return "JSON_VALIDATION_RULE_SCHEMA_NOTFOUND"
			case .NO_VACCINATION_CERTIFICATE:
				return "NO_VACCINATION_CERTIFICATE"
			case .NO_PASSED_RESULT:
				return "NO_PASSED_RESULT"
			}
		case .CERTIFICATE_VALIDATION_ERROR(let validationError):
			switch validationError {
			case .TECHNICAL_VALIDATION_FAILED(expirationDate: _, signatureInvalid: let signatureInvalid):
				return "TECHNICAL_VALIDATION_FAILED, signatureInvalid: \(signatureInvalid)"
			case .VALUE_SET_SERVER_ERROR:
				return "VALUE_SET_SERVER_ERROR"
			case .VALUE_SET_CLIENT_ERROR:
				return "VALUE_SET_CLIENT_ERROR"
			case .RULES_VALIDATION_ERROR:
				return "RULES_VALIDATION_ERROR"
			case let .rulesDownloadError(downloadError):
				switch downloadError {
				case .NO_NETWORK:
					return "NO_NETWORK"
				case .RULE_DECODING_ERROR:
					return "RULE_DECODING_ERROR"
				case .RULE_CLIENT_ERROR:
					return "RULE_CLIENT_ERROR"
				case .RULE_JSON_ARCHIVE_ETAG_ERROR:
					return "RULE_JSON_ARCHIVE_ETAG_ERROR"
				case .RULE_JSON_ARCHIVE_FILE_MISSING:
					return "RULE_JSON_ARCHIVE_FILE_MISSING"
				case .RULE_JSON_ARCHIVE_SIGNATURE_INVALID:
					return "RULE_JSON_ARCHIVE_SIGNATURE_INVALID"
				case .RULE_MISSING_CACHE:
					return "RULE_MISSING_CACHE"
				case .RULE_SERVER_ERROR:
					return "RULE_SERVER_ERROR"
				}
			}
		}
	}
	#endif
}

// swiftlint:disable pattern_matching_keywords
extension BoosterNotificationServiceError: Equatable {
	static func == (lhs: BoosterNotificationServiceError, rhs: BoosterNotificationServiceError) -> Bool {
		switch (lhs, rhs) {
		case (.CERTIFICATE_VALIDATION_ERROR(let lhsError), .CERTIFICATE_VALIDATION_ERROR(let rhsError)):
			return lhsError == rhsError
		case (.BOOSTER_VALIDATION_ERROR(let lhsError), .BOOSTER_VALIDATION_ERROR(let rhsError)):
			return lhsError == rhsError
		case (.BOOSTER_VALIDATION_ERROR, .CERTIFICATE_VALIDATION_ERROR):
			return false
		case (.CERTIFICATE_VALIDATION_ERROR, .BOOSTER_VALIDATION_ERROR):
			return false
		}
	}
}
