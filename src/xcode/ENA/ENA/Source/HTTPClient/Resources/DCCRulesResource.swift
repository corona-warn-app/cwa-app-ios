//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct DCCRulesResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		ruleType: HealthCertificateValidationRuleType
	) {
		self.locator = .DCCRules(ruleType: ruleType, isFake: isFake)
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ValidationRules>()
	}

	// MARK: - Overrides

	// MARK: - Protocol Resource

	typealias CustomError = HealthCertificateValidationError

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationRules>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
}

enum HealthCertificateValidationError: LocalizedError {

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
	case RULE_DECODING_ERROR(HealthCertificateValidationRuleType, RuleValidationError)
	case RULE_CLIENT_ERROR(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_ETAG_ERROR(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_FILE_MISSING(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_SIGNATURE_INVALID(HealthCertificateValidationRuleType)
	case RULE_MISSING_CACHE(HealthCertificateValidationRuleType)
	case RULE_SERVER_ERROR(HealthCertificateValidationRuleType)
	case NO_NETWORK
	case VALUE_SET_SERVER_ERROR
	case VALUE_SET_CLIENT_ERROR
	case RULES_VALIDATION_ERROR(RuleValidationError)

	var errorDescription: String? {
		switch self {
		case .TECHNICAL_VALIDATION_FAILED:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (TECHNICAL_VALIDATION_FAILED)"
		case let .RULE_DECODING_ERROR(ruleType, error):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_DECODING_ERROR - \(error)"
		case let .RULE_CLIENT_ERROR(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_CLIENT_ERROR)"
		case let .RULE_JSON_ARCHIVE_ETAG_ERROR(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_JSON_ARCHIVE_ETAG_ERROR)"
		case let .RULE_JSON_ARCHIVE_FILE_MISSING(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_JSON_ARCHIVE_FILE_MISSING)"
		case let .RULE_JSON_ARCHIVE_SIGNATURE_INVALID(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_JSON_ARCHIVE_SIGNATURE_INVALID)"
		case let .RULE_MISSING_CACHE(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_MISSING_CACHE)"
		case let .RULE_SERVER_ERROR(ruleType):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (\(ruleType.errorPrefix)_RULE_SERVER_ERROR)"
		case .NO_NETWORK:
			return "\(AppStrings.HealthCertificate.Validation.Error.noNetwork) (NO_NETWORK)"
		case .VALUE_SET_SERVER_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (VALUE_SET_SERVER_ERROR)"
		case .VALUE_SET_CLIENT_ERROR:
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (VALUE_SET_CLIENT_ERROR)"
		case let .RULES_VALIDATION_ERROR(error):
			return "\(AppStrings.HealthCertificate.Validation.Error.tryAgain) (RULES_VALIDATION_ERROR - \(error)"
		}
	}
}
