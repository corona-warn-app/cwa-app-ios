//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

struct DCCRulesResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false,
		ruleType: HealthCertificateValidationRuleType,
		trustEvaluation: TrustEvaluating = DefaultTrustEvaluation(
			publicKeyHash: Environments().currentEnvironment().pinningKeyHashData
		)
	) {
		self.locator = .DCCRules(ruleType: ruleType, isFake: isFake)

		if ruleType == .boosterNotification {
			self.type = .caching(
				Set<CacheUsePolicy>([.loadOnlyOnceADay])
			)
		} else if ruleType == .invalidation {
			self.type = .caching(
				Set<CacheUsePolicy>([.loadOnlyOnceADay])
			)
		} else {
			self.type = .caching()
		}

		#if !RELEASE
		// Debug menu: Force update of CCLConfiguration and Booster Notification Rules.
		if ruleType == .boosterNotification &&
			UserDefaults.standard.bool(forKey: CCLConfigurationResource.keyForceUpdateCCLConfiguration) {
			self.type = .default
		}
		#endif
		
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<DCCRulesReceiveModel>()
		self.ruleType = ruleType
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<DCCRulesReceiveModel>
	typealias CustomError = DCCDownloadRulesError

	let trustEvaluation: TrustEvaluating
	let ruleType: HealthCertificateValidationRuleType

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<DCCRulesReceiveModel>

	func customError(
		for error: ServiceError<DCCDownloadRulesError>,
		responseBody: Data? = nil
	) -> DCCDownloadRulesError? {
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

	// MARK: - Private

	private func handleResourceError(_ error: ResourceError?) -> DCCDownloadRulesError? {
		guard let error = error else {
			return nil
		}
		switch error {
		case .missingCache:
			return .RULE_MISSING_CACHE(ruleType)
		case .missingData, .packageCreation:
			return .RULE_JSON_ARCHIVE_FILE_MISSING(ruleType)
		case .decoding(let decodingError):
			return .RULE_DECODING_ERROR(ruleType, decodingError)
		case .signatureVerification:
			return .RULE_JSON_ARCHIVE_SIGNATURE_INVALID(ruleType)
		case .missingEtag:
			return .RULE_JSON_ARCHIVE_ETAG_ERROR(ruleType)
		default:
			return nil
		}
	}

}

enum DCCDownloadRulesError: LocalizedError, Equatable {

	// MARK: - Protocol Equatable

	static func == (lhs: DCCDownloadRulesError, rhs: DCCDownloadRulesError) -> Bool {
		return lhs.localizedDescription == rhs.localizedDescription
	}

	// MARK: - Internal

	case RULE_DECODING_ERROR(HealthCertificateValidationRuleType, ModelDecodingError)
	case RULE_CLIENT_ERROR(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_ETAG_ERROR(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_FILE_MISSING(HealthCertificateValidationRuleType)
	case RULE_JSON_ARCHIVE_SIGNATURE_INVALID(HealthCertificateValidationRuleType)
	case RULE_MISSING_CACHE(HealthCertificateValidationRuleType)
	case RULE_SERVER_ERROR(HealthCertificateValidationRuleType)
	case NO_NETWORK

	var errorDescription: String? {
		switch self {
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
		}
	}
}
