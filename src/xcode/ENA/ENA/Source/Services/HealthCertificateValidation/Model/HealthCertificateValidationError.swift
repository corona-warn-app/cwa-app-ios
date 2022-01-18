//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

enum HealthCertificateValidationError: LocalizedError, Equatable {

	// MARK: - Protocol Equatable

	static func == (lhs: HealthCertificateValidationError, rhs: HealthCertificateValidationError) -> Bool {

		switch (lhs, rhs) {
		case let (.TECHNICAL_VALIDATION_FAILED(lhsExpirationDate, lhsSignatureInvalid), .TECHNICAL_VALIDATION_FAILED(rhsExpirationDate, rhsSignatureInvalid)):
			return lhsExpirationDate == rhsExpirationDate && lhsSignatureInvalid == rhsSignatureInvalid
		default:
			return lhs.localizedDescription == rhs.localizedDescription
		}
	}

	// MARK: - Internal

	case TECHNICAL_VALIDATION_FAILED(expirationDate: Date?, signatureInvalid: Bool)
	case VALUE_SET_SERVER_ERROR
	case VALUE_SET_CLIENT_ERROR
	case RULES_VALIDATION_ERROR(RuleValidationError)
	case rulesDownloadError(DCCDownloadRulesError)

	var errorDescription: String? {
		switch self {
		case .TECHNICAL_VALIDATION_FAILED:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (TECHNICAL_VALIDATION_FAILED)"
		case .VALUE_SET_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (VALUE_SET_SERVER_ERROR)"
		case .VALUE_SET_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (VALUE_SET_CLIENT_ERROR)"
		case let .RULES_VALIDATION_ERROR(error):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (RULES_VALIDATION_ERROR - \(error)"
		case let .rulesDownloadError(downloadError):
			return downloadError.errorDescription
		}
	}
}
