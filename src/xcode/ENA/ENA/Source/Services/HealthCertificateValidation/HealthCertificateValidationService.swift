////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit
// Do not import everything, just the datatypes we need to make a clean cut.
import enum CertLogic.RuleType
import enum CertLogic.CertificateType
import class CertLogic.Rule
import class CertLogic.ExternalParameter
import class CertLogic.FilterParameter
import class CertLogic.ValidationResult

protocol HealthCertificateValidationProviding {
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	)
}

/*
General flow:
1. apply technical validation (expirationTimes)
2. download new certificate value sets or load them from the cache
3. download new acceptance rules or load them from the cache
4. download new invalidation rules or load them from the cache
5. assemble FilterParameter and ExternalParameter
6. validate combined acceptance and invalidation rules
7. return interpreted rules
*/

// swiftlint:disable:next type_body_length
final class HealthCertificateValidationService: HealthCertificateValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider,
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		validationRulesAccess: ValidationRulesAccessing = ValidationRulesAccess()
	) {
		self.store = store
		self.client = client
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.signatureVerifier = signatureVerifier
		self.validationRulesAccess = validationRulesAccess
	}
		
	// MARK: - Protocol HealthCertificateValidationProviding
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 1. Apply technical validation
		let expirationDate = Date(timeIntervalSince1970: TimeInterval(healthCertificate.cborWebTokenHeader.expirationTime))
		
		// NOTE: We expect here a HealthCertificate, which was already json schema validated at its creation time. So the JsonSchemaCheck will here always be true. So we only have to check for the expirationTime of the certificate.
		guard expirationDate >= validationClock else {
			Log.warning("Technical validation failed: expirationDate < validationClock. Expiration date: \(private: expirationDate), validationClock: \(private: validationClock)", log: .vaccination)
			return completion(.failure(.TECHNICAL_VALIDATION_FAILED))
		}
		Log.info("Successfully passed technical validation. Proceed with updating value sets...", log: .vaccination)

		proceedWithUpdatingValueSets(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			completion: completion
		)
	}
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private let signatureVerifier: SignatureVerification
	private let validationRulesAccess: ValidationRulesAccessing
	private var subscriptions = Set<AnyCancellable>()
	
	// MARK: - Flow
	
	private func proceedWithUpdatingValueSets(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 2. update/ download value sets
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case let URLSession.Response.Failure.httpError(_, response) = error {
							switch response.statusCode {
							case 500...509:
								Log.error("Failed to update value sets with status code: \(response.statusCode)", log: .vaccination, error: error)
								completion(.failure(.VALUE_SET_SERVER_ERROR))
							default:
								Log.error("Unhandled Status Code while fetching certificate value sets", log: .vaccination, error: error)
								completion(.failure(.VALUE_SET_CLIENT_ERROR))
							}
							
						} else if case URLSession.Response.Failure.noNetworkConnection = error {
							Log.error("Failed to update value sets. No network error", log: .vaccination, error: error)
							completion(.failure(.NO_NETWORK))
						} else {
							Log.error("Casting error for http error", log: .vaccination, error: error)
							completion(.failure(.VALUE_SET_CLIENT_ERROR))
						}
					}
					
				}, receiveValue: { [weak self] valueSets in
					Log.info("Successfully received value sets. Proceed with downloading acceptance rules...", log: .vaccination)
					self?.proceedWithDownloadingAcceptanceRules(
						healthCertificate: healthCertificate,
						arrivalCountry: arrivalCountry,
						validationClock: validationClock,
						valueSets: valueSets,
						completion: completion
					)
				}
			)
			.store(in: &subscriptions)
	}
	
	private func proceedWithDownloadingAcceptanceRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 3. update/ download acceptance rules
		downloadRules(
			ruleType: .invalidation,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(acceptanceRules):
					Log.info("Successfully downloaded/restored acceptance rules. Proceed with downloading invalidation rules...", log: .vaccination)
					self?.proceedWithDownloadingInvalidationRules(
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
	
	private func proceedWithDownloadingInvalidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 4. update/ download invalidation rules
		downloadRules(
			ruleType: .invalidation,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(invalidationRules):
					Log.info("Successfully downloaded/restored invalidation rules. Proceed with assembling FilterParameter...", log: .vaccination)
					self?.proceedWithAssemblingRules(
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
	
	private func proceedWithAssemblingRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 5. Assemble common FilterParameter
		
		let mappedCertificateType = mapForExternalParameter(healthCertificate.type)
		
		let filterParameter = FilterParameter(
			validationClock: validationClock,
			countryCode: arrivalCountry,
			certificationType: mappedCertificateType,
			region: nil
		)
		
		Log.info("Successfully assembled common FilterParameter: \(private: filterParameter). Proceed with assembling common ExternalParameter...", log: .vaccination)
		
		// Assemble common ExternalParameter
		
		let mappedValueSets = mapValueSetsForExternalParameter(valueSet: valueSets)
		let exp = mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.expirationTime)
		let iat = mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.issuedAt)
		
		let externalParameter = ExternalParameter(
			validationClock: validationClock,
			valueSets: mappedValueSets,
			exp: exp,
			iat: iat,
			issuerCountryCode: healthCertificate.cborWebTokenHeader.issuer,
			kid: healthCertificate.keyIdentifier
		)
		
		Log.info("Successfully assembled common ExternalParameter: \(private: externalParameter). Proceed with rule validation...", log: .vaccination)

		proceedWithRulesValidation(
			healthCertificate: healthCertificate,
			valueSets: valueSets,
			acceptanceRules: acceptanceRules,
			invalidationRules: invalidationRules,
			filterParameter: filterParameter,
			externalParameter: externalParameter,
			completion: completion
		)
	}
	
	private func proceedWithRulesValidation(
		healthCertificate: HealthCertificate,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		filterParameter: FilterParameter,
		externalParameter: ExternalParameter,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 6. apply acceptance and invalidation rules together and validate them
		
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

		proceedWithRulesInterpretation(
			validatedRules: validatedRules,
			completion: completion
		)
		
	}
	
	private func proceedWithRulesInterpretation(
		validatedRules: [ValidationResult],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 7. interpret rules
		
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
	
	// MARK: - Rules downloading and extraction
		
	private func downloadRules(
		ruleType: HealthCertificateValidationRuleType,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		var eTag: String?
		switch ruleType {
		case .acceptance:
			eTag = store.acceptanceRulesCache?.lastValidationRulesETag
		case .invalidation:
			eTag = store.invalidationRulesCache?.lastValidationRulesETag
		}
		
		client.getDCCRules(
			eTag: eTag,
			isFake: false,
			ruleType: ruleType,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self", log: .vaccination)
					switch ruleType {
					case .acceptance:
						completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
					case .invalidation:
						completion(.failure(.INVALIDATION_RULE_CLIENT_ERROR))
					}
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.rulesDownloadingSuccessHandler(
						ruleType: ruleType,
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
	
				case let .failure(failure):
					self.rulesDownloadingFailureHandler(
						ruleType: ruleType,
						failure: failure,
						completion: completion
					)
				}
			}
		)
	}
	
	// Disable swiftlint for cyclomatic_complexity because it rants only due to the many switches over the rule type.
	// swiftlint:disable:next cyclomatic_complexity
	private func rulesDownloadingSuccessHandler(
		ruleType: HealthCertificateValidationRuleType,
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Successfully received \(ruleType) acceptance rules package. Proceed with eTag verification...", log: .vaccination)

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.", log: .vaccination)
			switch ruleType {
			case .acceptance:
				completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR))
			case .invalidation:
				completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_ETAG_ERROR))
			}
			return
		}
		Log.info("Successfully verified eTag. Proceed with package extraction...", log: .vaccination)
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.", log: .vaccination)
			switch ruleType {
			case .acceptance:
				completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING))
			case .invalidation:
				completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING))
			}
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...", log: .vaccination)
		
		guard signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure", log: .vaccination)
			switch ruleType {
			case .acceptance:
				completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			case .invalidation:
				completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			}
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
				}
				Log.info("Successfully stored \(ruleType) rules in cache.", log: .vaccination)
				completion(.success(rules))
				
			case let .failure(validationError):
				Log.error("Could not decode CBOR from package with error:", log: .vaccination, error: validationError)
				switch ruleType {
				case .acceptance:
					completion(.failure(.ACCEPTANCE_RULE_VALIDATION_ERROR(validationError)))
				case .invalidation:
					completion(.failure(.INVALIDATION_RULE_VALIDATION_ERROR(validationError)))
				}
			}
		})
	}
	// Disable swiftlint for cyclomatic_complexity because it rants only due to the many switches over the rule type.
	// swiftlint:disable:next cyclomatic_complexity
	private func rulesDownloadingFailureHandler(
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
					completion(.failure(.ACCEPTANCE_RULE_MISSING_CACHE))
				}
			case .invalidation:
				if let cachedInvalidationRules = store.invalidationRulesCache?.validationRules {
					completion(.success(cachedInvalidationRules))
				} else {
					// If not, return edge case error
					Log.error("Could not find cached invalidation rules but need some.", log: .vaccination)
					completion(.failure(.INVALIDATION_RULE_MISSING_CACHE))
				}
			}
		case .noNetworkConnection:
			Log.error("Could not download \(ruleType) rules due to no network.", log: .vaccination, error: failure)
			completion(.failure(.NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				Log.error("Could not download \(ruleType) rules due to client error with status code: \(statusCode).", log: .vaccination, error: failure)
				switch ruleType {
				case .acceptance:
					completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
				case .invalidation:
					completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
				}
			default:
				Log.error("Could not download \(ruleType) rules due to server error with status code: \(statusCode).", log: .vaccination, error: failure)
				switch ruleType {
				case .acceptance:
					completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
				case .invalidation:
					completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
				}
			}
		default:
			Log.error("Could not download \(ruleType) rules due to server error.", log: .vaccination, error: failure)
			switch ruleType {
			case .acceptance:
				completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
			case .invalidation:
				completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
			}
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
	
	private var allCountryCodes: [String] {
		// This list of country codes comes from our techspec 1:1 as it is. Because we want to keep the copied format, we disable swiftlint here.
		// swiftlint:disable line_length
		// swiftlint:disable comma
		return ["AD","AE","AF","AG","AI","AL","AM","AO","AQ","AR","AS","AT","AU","AW","AX","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BJ","BL","BM","BN","BO","BQ","BR","BS","BT","BV","BW","BY","BZ","CA","CC","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","CR","CU","CV","CW","CX","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EE","EG","EH","ER","ES","ET","FI","FJ","FK","FM","FO","FR","GA","GB","GD","GE","GF","GG","GH","GI","GL","GM","GN","GP","GQ","GR","GS","GT","GU","GW","GY","HK","HM","HN","HR","HT","HU","ID","IE","IL","IM","IN","IO","IQ","IR","IS","IT","JE","JM","JO","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MF","MG","MH","MK","ML","MM","MN","MO","MP","MQ","MR","MS","MT","MU","MV","MW","MX","MY","MZ","NA","NC","NE","NF","NG","NI","NL","NO","NP","NR","NU","NZ","OM","PA","PE","PF","PG","PH","PK","PL","PM","PN","PR","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SH","SI","SJ","SK","SL","SM","SN","SO","SR","SS","ST","SV","SX","SY","SZ","TC","TD","TF","TG","TH","TJ","TK","TL","TM","TN","TO","TR","TT","TV","TW","TZ","UA","UG","UM","US","UY","UZ","VA","VC","VE","VG","VI","VN","VU","WF","WS","YE","YT","ZA","ZM","ZW"]
	}
		
	/// Maps our valueSet on the value set of CertLogic. See https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/business-rules-dcc/docs/spec/dgc-validation-rules-client.md#data-structure-of-external-rule-parameters
	private func mapValueSetsForExternalParameter(
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
	
	private func mapForExternalParameter(_ certificateType: HealthCertificate.CertificateType) -> CertLogic.CertificateType {
		switch certificateType {
		case .vaccination:
			return .vaccination
		case .test:
			return .test
		case .recovery:
			return .recovery
		}
	}
	
	private func mapUnixTimestampsInSecondsToDate(_ timestamp: UInt64) -> Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}
