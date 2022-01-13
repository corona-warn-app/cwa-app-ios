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
		self.ruleType = ruleType
	}

	// MARK: - Overrides

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ValidationRules>
	typealias CustomError = HealthCertificateValidationError

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationRules>

	func customError(for error: ServiceError<HealthCertificateValidationError>) -> HealthCertificateValidationError? {
		switch error {
		case .transportationError:
			return .NO_NETWORK
		case .unexpectedServerError(let statusCode):
					switch statusCode {
					case (400...499):
						return .RULE_CLIENT_ERROR(ruleType)
					default:
						return .RULE_SERVER_ERROR(ruleType)
					}
		case let .resourceError(resourceError):
			return handleResourceError(resourceError)
		default:
			return nil
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let ruleType: HealthCertificateValidationRuleType

	private func handleResourceError(_ error: ResourceError?) -> HealthCertificateValidationError? {
		guard let error = error else {
			return nil
		}
		switch error {
		case .missingCache:
			return .RULE_MISSING_CACHE(ruleType)
		case .missingData, .packageCreation:
			return .RULE_JSON_ARCHIVE_FILE_MISSING(ruleType)
		case .decoding(let dError):
			if let ruleValidationError = dError as? RuleValidationError {
				return .RULE_DECODING_ERROR(ruleType, ruleValidationError)
			} else {
				return .RULE_DECODING_ERROR(ruleType, RuleValidationError.CBOR_DECODING_FAILED(error))
			}
		case .signatureVerification:
			return .RULE_JSON_ARCHIVE_SIGNATURE_INVALID(ruleType)
		case .missingEtag:
			return .RULE_JSON_ARCHIVE_ETAG_ERROR(ruleType)
		default:
			return nil
		}
	}

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
