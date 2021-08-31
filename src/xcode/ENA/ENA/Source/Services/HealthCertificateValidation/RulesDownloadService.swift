//
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

import enum CertLogic.RuleType
import enum CertLogic.CertificateType
import class CertLogic.Rule
import class CertLogic.ExternalParameter
import class CertLogic.FilterParameter
import class CertLogic.ValidationResult

protocol ValidationRulesDownloadServiceProviding {
	func prepareAndDownloadValidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	)
}

protocol BoosterNotificationsRulesDownloadServiceProviding {
	func downloadBoosterNotificationRules(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	)
}

class RulesDownloadService: ValidationRulesDownloadServiceProviding, BoosterNotificationsRulesDownloadServiceProviding {
	
	// MARK: - Init

	init (
		validationRulesAccess: ValidationRulesAccessing = ValidationRulesAccess(),
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		store: Store,
		client: Client
	) {
		self.validationRulesAccess = validationRulesAccess
		self.signatureVerifier = signatureVerifier
		self.store = store
		self.client = client
	}
	
	// MARK: - Protocol RulesDownloadServiceProviding
	
	// Booster Notification Rules downloading and extraction
	func downloadBoosterNotificationRules(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		client.getBoosterNotificationRules(
			eTag: nil, isFake: false,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self", log: .vaccination)
					completion(.failure(.RULE_CLIENT_ERROR(.invalidation)))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					Log.error("Could not create strong self")
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

	// Validation Rules Preparation
	func prepareAndDownloadValidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 1. update/ download acceptance rules
		downloadValidationRules(
			ruleType: .acceptance,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(acceptanceRules):
					Log.info("Successfully downloaded/restored acceptance rules. Proceed with downloading invalidation rules...", log: .vaccination)
					self?.downloadInvalidationRules(
						healthCertificate: healthCertificate,
						arrivalCountry: arrivalCountry,
						validationClock: validationClock,
						valueSets: valueSets,
						acceptanceRules: acceptanceRules,
						completion: completion
					)
				}
			}
		)
	}
	
	// MARK: - Private

	private let store: Store
	private let client: Client
	private let validationRulesAccess: ValidationRulesAccessing
	private let signatureVerifier: SignatureVerification

	private func downloadInvalidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 2. update/ download invalidation rules
		downloadValidationRules(
			ruleType: .invalidation,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(invalidationRules):
					Log.info("Successfully downloaded/restored invalidation rules. Proceed with assembling FilterParameter...", log: .vaccination)
					self?.assembleCommonRules(
						healthCertificate: healthCertificate,
						arrivalCountry: arrivalCountry,
						validationClock: validationClock,
						valueSets: valueSets,
						acceptanceRules: acceptanceRules,
						invalidationRules: invalidationRules,
						completion: completion
					)
				}
			}
		)
	}
	
	private func assembleCommonRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 3. Assemble common FilterParameter
		
		let mappedCertificateType = mapCertificateType(healthCertificate.type)
		
		// we must not set the region at the moment, so we set it to nil.
		let filterParameter = FilterParameter(
			validationClock: validationClock,
			countryCode: arrivalCountry.id,
			certificationType: mappedCertificateType,
			region: nil
		)
		
		Log.info("Successfully assembled common FilterParameter: \(private: filterParameter). Proceed with assembling common ExternalParameter...", log: .vaccination)
		
		// Assemble common ExternalParameter
		
		let mappedValueSets = mapValueSets(valueSet: valueSets)
		let exp = healthCertificate.cborWebTokenHeader.expirationTime
		let iat = healthCertificate.cborWebTokenHeader.issuedAt
		
		let externalParameter = ExternalParameter(
			validationClock: validationClock,
			valueSets: mappedValueSets,
			exp: exp,
			iat: iat,
			issuerCountryCode: healthCertificate.cborWebTokenHeader.issuer,
			kid: healthCertificate.keyIdentifier
		)
		
		Log.info("Successfully assembled common ExternalParameter: \(private: externalParameter). Proceed with rule validation...", log: .vaccination)

		validateRules(
			healthCertificate: healthCertificate,
			valueSets: valueSets,
			acceptanceRules: acceptanceRules,
			invalidationRules: invalidationRules,
			filterParameter: filterParameter,
			externalParameter: externalParameter,
			completion: completion
		)
	}
	
	private func validateRules(
		healthCertificate: HealthCertificate,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		filterParameter: FilterParameter,
		externalParameter: ExternalParameter,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 4. apply acceptance and invalidation rules together and validate them
		
		let combinedRules = acceptanceRules + invalidationRules
		
		let validationRulesResult = validationRulesAccess.applyValidationRules(
			combinedRules,
			to: healthCertificate.digitalCovidCertificate,
			filter: filterParameter,
			externalRules: externalParameter
		)

		guard case let .success(validatedRules) = validationRulesResult else {
			if case let .failure(error) = validationRulesResult {
				Log.error("Could not validate rules.", log: .vaccination, error: error)
				completion(.failure(.RULES_VALIDATION_ERROR(error)))
			}
			return
		}
		
		Log.info("Successfully validated combined rules: \(private: validatedRules). Proceed with combined rule interpretation...", log: .vaccination)

		interpretateRulesResult(
			validatedRules: validatedRules,
			completion: completion
		)
		
	}
	
	private func interpretateRulesResult(
		validatedRules: [ValidationResult],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 5. interpret rules
		
		if validatedRules.allSatisfy({ $0.result == .passed }) {
			// all rules has to be .passed
			Log.info("Validation result is: validationPassed. Validation complete.", log: .vaccination)
			completion(.success(.validationPassed(validatedRules)))
		} else if validatedRules.contains(where: { $0.result == .open }) &&
					!validatedRules.contains(where: { $0.result == .fail }) {
			// At least one rule should contain now .open and there is no .fail
			Log.info("Validation result is: validationOpen. Validation complete.", log: .vaccination)
			completion(.success(.validationOpen(validatedRules)))
		} else {
			// At least one rule should contain now .fail
			Log.info("Validation result is: validationFailed. Validation complete.", log: .vaccination)
			completion(.success(.validationFailed(validatedRules)))
		}
	}
	
	// MARK: - Normal Validation Rules downloading and extraction
		
	private func downloadValidationRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		var eTag: String?
		switch ruleType {
		case .acceptance:
			eTag = store.acceptanceRulesCache?.lastValidationRulesETag
		case .invalidation:
			eTag = store.invalidationRulesCache?.lastValidationRulesETag
		case .boosterNotification:
			eTag = store.boosterRulesCache?.lastValidationRulesETag
		}
		
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
				}
				
				Log.info("Successfully stored \(ruleType) rules in cache.", log: .vaccination)
				completion(.success(rules))
				
			case let .failure(validationError):
				Log.error("Could not decode CBOR from package with error:", log: .vaccination, error: validationError)
				completion(.failure(.RULE_DECODING_ERROR(ruleType, validationError)))

			}
		})
	}
	
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
	
	// MARK: - ExternalParameters helpers
	
	// Internal for testing purposes
	var allCountryCodes: [String] {
		// This list of country codes comes from our techspec 1:1 as it is. Because we want to keep the copied format, we disable swiftlint here.
		// swiftlint:disable line_length
		// swiftlint:disable comma
		return ["AD","AE","AF","AG","AI","AL","AM","AO","AQ","AR","AS","AT","AU","AW","AX","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BJ","BL","BM","BN","BO","BQ","BR","BS","BT","BV","BW","BY","BZ","CA","CC","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","CR","CU","CV","CW","CX","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EE","EG","EH","ER","ES","ET","FI","FJ","FK","FM","FO","FR","GA","GB","GD","GE","GF","GG","GH","GI","GL","GM","GN","GP","GQ","GR","GS","GT","GU","GW","GY","HK","HM","HN","HR","HT","HU","ID","IE","IL","IM","IN","IO","IQ","IR","IS","IT","JE","JM","JO","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MF","MG","MH","MK","ML","MM","MN","MO","MP","MQ","MR","MS","MT","MU","MV","MW","MX","MY","MZ","NA","NC","NE","NF","NG","NI","NL","NO","NP","NR","NU","NZ","OM","PA","PE","PF","PG","PH","PK","PL","PM","PN","PR","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SH","SI","SJ","SK","SL","SM","SN","SO","SR","SS","ST","SV","SX","SY","SZ","TC","TD","TF","TG","TH","TJ","TK","TL","TM","TN","TO","TR","TT","TV","TW","TZ","UA","UG","UM","US","UY","UZ","VA","VC","VE","VG","VI","VN","VU","WF","WS","YE","YT","ZA","ZM","ZW"]
	}
		

	// Maps our valueSet on the value set of CertLogic. See https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/business-rules-dcc/docs/spec/dgc-validation-rules-client.md#data-structure-of-external-rule-parameters
	// Internal for testing purposes
	func mapValueSets(
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> [String: [String]] {
		var dictionary = [String: [String]]()
		dictionary["country-2-codes"] = allCountryCodes
		dictionary["covid-19-lab-result"] = valueSet.tcTr.items.map { $0.key }
		dictionary["covid-19-lab-test-manufacturer-and-name"] = valueSet.tcMa.items.map { $0.key }
		dictionary["covid-19-lab-test-type"] = valueSet.tcTt.items.map { $0.key }
		dictionary["disease-agent-targeted"] = valueSet.tg.items.map { $0.key }
		dictionary["sct-vaccines-covid-19"] = valueSet.vp.items.map { $0.key }
		dictionary["vaccines-covid-19-auth-holders"] = valueSet.ma.items.map { $0.key }
		dictionary["vaccines-covid-19-names"] = valueSet.mp.items.map { $0.key }
		return dictionary
	}

	// Internal for testing purposes
	func mapCertificateType(_ certificateType: HealthCertificate.CertificateType) -> CertLogic.CertificateType {
		switch certificateType {
		case .vaccination:
			return .vaccination
		case .test:
			return .test
		case .recovery:
			return .recovery
		}
	}
}
