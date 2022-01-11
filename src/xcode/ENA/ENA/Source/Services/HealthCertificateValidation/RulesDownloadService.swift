//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit
import class CertLogic.Rule

protocol RulesDownloadServiceProviding {
	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	)
}

class RulesDownloadService: RulesDownloadServiceProviding {
	
	// MARK: - Init

	init (
		validationRulesAccess: ValidationRulesAccessing = ValidationRulesAccess(),
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		store: Store,
		client: Client,  // client will be removed if no longer needed later
		restServiceProvider: RestServiceProviding
	) {
		self.validationRulesAccess = validationRulesAccess
		self.signatureVerifier = signatureVerifier
		self.store = store
		self.client = client
		self.restServiceProvider = restServiceProvider
	}
	
	// MARK: - Protocol RulesDownloadServiceProviding
	
	func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		switch ruleType {
		case .acceptance:
			let eTag = store.acceptanceRulesCache?.lastValidationRulesETag
			downloadValidationRules(eTag: eTag, ruleType: ruleType, completion: completion)
			
		case .invalidation:
			let eTag = store.invalidationRulesCache?.lastValidationRulesETag
			downloadValidationRules(eTag: eTag, ruleType: ruleType, completion: completion)
			
		case .boosterNotification:
			let eTag = store.boosterRulesCache?.lastValidationRulesETag
			downloadBoosterRules(eTag: eTag, ruleType: ruleType, completion: completion)
		}
	}
	
	// MARK: - Private

	private let store: Store
	private let client: Client
	private let restServiceProvider: RestServiceProviding
	private let validationRulesAccess: ValidationRulesAccessing
	private let signatureVerifier: SignatureVerification
		
	private func downloadValidationRules(
		eTag: String?,
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Download validation rules.")
		
		client.getDCCRules(
			eTag: eTag,
			isFake: false,
			ruleType: ruleType,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self", log: .vaccination)
					completion(.failure(.RULE_CLIENT_ERROR(ruleType)))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.rulesDownloadingSuccess(
						ruleType: ruleType,
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
	
				case let .failure(failure):
					self.rulesDownloadingFailure(
						ruleType: ruleType,
						failure: failure,
						completion: completion
					)
				}
			}
		)
	}
	
	private func downloadBoosterRules(
		eTag: String?,
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Download booster rules.")

		client.getBoosterNotificationRules(
			eTag: eTag,
			isFake: false,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self", log: .vaccination)
					completion(.failure(.RULE_CLIENT_ERROR(.invalidation)))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					Log.debug("Successfully downloaded new booster rules package")
					self.rulesDownloadingSuccess(
						ruleType: .boosterNotification,
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
					
				case let .failure(failure):
					Log.error("Could not create strong self")
					self.rulesDownloadingFailure(
						ruleType: .boosterNotification,
						failure: failure,
						completion: completion
					)
				}
			}
		)
	}
	
	// MARK: - Common helper methods for caching all types of rules

	private func rulesDownloadingSuccess(
		ruleType: HealthCertificateValidationRuleType,
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Successfully received \(ruleType) rules package. Proceed with eTag verification...", log: .vaccination)

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.", log: .vaccination)
			completion(.failure(.RULE_JSON_ARCHIVE_ETAG_ERROR(ruleType)))
			return
		}
		Log.info("Successfully verified eTag. Proceed with package extraction...", log: .vaccination)
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.", log: .vaccination)
			completion(.failure(.RULE_JSON_ARCHIVE_FILE_MISSING(ruleType)))

			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...", log: .vaccination)
		
		guard signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure", log: .vaccination)
			completion(.failure(.RULE_JSON_ARCHIVE_SIGNATURE_INVALID(ruleType)))

			return
		}
		Log.info("Successfully verified sapDownloadedPackage. Proceed now with CBOR decoding...", log: .vaccination)
		
		self.extractRules(sapDownloadedPackage.bin, completion: { result in
			switch result {
			case let .success(rules):
				Log.info("Successfully decoded \(ruleType) rules: \(private: rules).", log: .vaccination)
				// Save in success case for caching
				switch ruleType {
				case .acceptance:
					let receivedAcceptanceRules = ValidationRulesCache(
						lastValidationRulesETag: eTag,
						validationRules: rules
					)
					store.acceptanceRulesCache = receivedAcceptanceRules
				case .invalidation:
					let receivedInvalidationRules = ValidationRulesCache(
						lastValidationRulesETag: eTag,
						validationRules: rules
					)
					store.invalidationRulesCache = receivedInvalidationRules
				case .boosterNotification:
					let receivedBoosterRules = ValidationRulesCache(
						lastValidationRulesETag: eTag,
						validationRules: rules
					)
					store.boosterRulesCache = receivedBoosterRules
					if !rules.isEmpty {
						store.lastBoosterNotificationsExecutionDate = Date()
					}
				}
				
				Log.info("Successfully stored \(ruleType) rules in cache.", log: .vaccination)
				completion(.success(rules))
				
			case let .failure(validationError):
				Log.error("Could not decode CBOR from package with error:", log: .vaccination, error: validationError)
				completion(.failure(.RULE_DECODING_ERROR(ruleType, validationError)))

			}
		})
	}
	
	// swiftlint:disable cyclomatic_complexity
	private func rulesDownloadingFailure(
		ruleType: HealthCertificateValidationRuleType,
		failure: URLSession.Response.Failure,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		switch failure {
		case .notModified:
			// Normally we should have cached something before
			Log.info("Download new \(ruleType) rules aborted due to not modified content. Taking cached rules.", log: .vaccination)
			switch ruleType {
			case .acceptance:
				if let cachedAcceptanceRules = store.acceptanceRulesCache?.validationRules {
					completion(.success(cachedAcceptanceRules))
				} else {
					// If not, return edge case error
					Log.error("Could not find cached acceptance rules but need some.", log: .vaccination)
					completion(.failure(.RULE_MISSING_CACHE(.acceptance)))
				}
			case .invalidation:
				if let cachedInvalidationRules = store.invalidationRulesCache?.validationRules {
					completion(.success(cachedInvalidationRules))
				} else {
					// If not, return edge case error
					Log.error("Could not find cached invalidation rules but need some.", log: .vaccination)
					completion(.failure(.RULE_MISSING_CACHE(.invalidation)))
				}
			case .boosterNotification:
				if let cachedBoosterRules = store.boosterRulesCache?.validationRules {
					completion(.success(cachedBoosterRules))
				} else {
					// If not, return edge case error
					Log.error("Could not find cached boosterNotification rules but need some.", log: .vaccination)
					completion(.failure(.RULE_MISSING_CACHE(.boosterNotification)))
				}
			}
		case .noNetworkConnection:
			Log.error("Could not download \(ruleType) rules due to no network.", log: .vaccination, error: failure)
			completion(.failure(.NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				Log.error("Could not download \(ruleType) rules due to client error with status code: \(statusCode).", log: .vaccination, error: failure)
				completion(.failure(.RULE_CLIENT_ERROR(ruleType)))
			default:
				Log.error("Could not download \(ruleType) rules due to server error with status code: \(statusCode).", log: .vaccination, error: failure)
				completion(.failure(.RULE_SERVER_ERROR(ruleType)))
			}
		default:
			Log.error("Could not download \(ruleType) rules due to server error.", log: .vaccination, error: failure)
			completion(.failure(.RULE_SERVER_ERROR(ruleType)))
		}
	}
	
	private func extractRules(
		_ data: Data,
		completion: (Result<[Rule], RuleValidationError>) -> Void
	) {
		let extractRulesResult = validationRulesAccess.extractValidationRules(from: data)
		
		switch extractRulesResult {
		case let .success(rules):
			completion(.success(rules))
		case let .failure(error):
			completion(.failure(error))
		}
	}
}
