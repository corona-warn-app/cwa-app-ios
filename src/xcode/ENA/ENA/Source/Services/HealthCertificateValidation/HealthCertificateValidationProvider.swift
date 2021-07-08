////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit
// Do not import everything, just the datatypes we need to make a clean cut.
import class CertLogic.Rule
import class CertLogic.ExternalParameter
import class CertLogic.FilterParameter
import enum CertLogic.CertificateType
import class CertLogic.ValidationResult
import enum CertLogic.RuleType

protocol HealthCertificateValidationProviding {
	func onboardedCountries(
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	)
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	)
}

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
final class HealthCertificateValidationProvider: HealthCertificateValidationProviding {
	
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
	
	// MARK: - Overrides
	
	// MARK: - Protocol DCCValidationProviding
	
	func onboardedCountries(
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	) {
		client.validationOnboardedCountries(
			eTag: store.validationOnboardedCountriesCache?.lastOnboardedCountriesETag,
			isFake: false,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self", log: .vaccination)
					completion(.failure(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.processOnboardedCountriesResponse(
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
				case let .failure(error):
					self.processOnboardedCountriesFailure(
						error: error,
						completion: completion
					)
				}
			}
		)
	}
	
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
	
	// MARK: - Onboarded Countries
	
	private func processOnboardedCountriesResponse(
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	) {
		Log.info("Successfully received onboarded countries package. Proceed with eTag verification...", log: .vaccination)

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.", log: .vaccination)
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_ETAG_ERROR))
			return
		}
		
		Log.info("Successfully verified eTag. Proceed with package extraction...", log: .vaccination)
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.", log: .vaccination)
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING))
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...", log: .vaccination)
		
		guard signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure", log: .vaccination)
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		Log.info("Successfully verified sapDownloadedPackage. Proceed now with CBOR decoding...", log: .vaccination)
		
		extractCountryCodes(
			cborData: sapDownloadedPackage.bin,
			completion: { result in
				switch result {
				case let .success(countries):
					Log.info("Successfully decoded country codes: \(private: countries). Returning now.", log: .vaccination)
					// Save in success case for caching
					let receivedOnboardedCountries = HealthCertificateValidationOnboardedCountriesCache(
						onboardedCountries: countries,
						lastOnboardedCountriesETag: eTag
					)
					store.validationOnboardedCountriesCache = receivedOnboardedCountries
					completion(.success(countries))
				case let .failure(error):
					Log.error("Could not decode CBOR from package with error:", log: .vaccination, error: error)
					completion(.failure(error))
				}
			}
		)
	}
	
	private func processOnboardedCountriesFailure(
		error: URLSession.Response.Failure,
		completion: @escaping (Result<[Country], HealthCertificateValidationOnboardedCountriesError>) -> Void
	) {
		switch error {
		case .notModified:
			// Normally we should have cached something before
			if let cachedOnboardedCountries = store.validationOnboardedCountriesCache?.onboardedCountries {
				completion(.success(cachedOnboardedCountries))
			} else {
				// If not, return edge case error
				completion(.failure(.ONBOARDED_COUNTRIES_MISSING_CACHE))
			}
		case .noNetworkConnection:
			completion(.failure(.ONBOARDED_COUNTRIES_NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				completion(.failure(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
			default:
				completion(.failure(.ONBOARDED_COUNTRIES_SERVER_ERROR))
			}
		default:
			completion(.failure(.ONBOARDED_COUNTRIES_SERVER_ERROR))
		}
	}
	
	/// Extracts by the HealthCertificateToolkit the list of countrys. Expects the list as CBOR-Data and return for success the list of Country-Objects.
	private func extractCountryCodes(
		cborData: Data,
		completion: (Result<[Country], HealthCertificateValidationOnboardedCountriesError>
		) -> Void
	) {
		let extractOnboardedCountryCodesResult = OnboardedCountriesAccess().extractCountryCodes(from: cborData)
		
		switch extractOnboardedCountryCodesResult {
		case let .success(countryCodes):
			let countries = countryCodes.compactMap {
				Country(countryCode: $0)
			}
			completion(.success(countries))
		case .failure:
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_DECODING_FAILED))
		}
	}
	
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
					Log.info("Successfully downloaded/restored invalidation rules. Proceed with assembling external rule parameters...", log: .vaccination)
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
		// 6. assemble external rule params for acceptance rules
		let acceptanceRuleParameter = assembleAcceptanceExternalRuleParameters(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			valueSet: valueSets
		)
		Log.info("Successfully assembled acceptance rule parameter: \(private: acceptanceRuleParameter). Proceed with invalidation rule parameter...", log: .vaccination)

		// 8. assemble external rule params for invalidation rules
		let invalidationRuleParameter = assembleInvalidationExternalRuleParameters(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			valueSet: valueSets
		)
		Log.info("Successfully assembled invalidation rule parameter: \(private: invalidationRuleParameter). Proceed with rule validation...", log: .vaccination)

		proceedWithRulesValidation(
			healthCertificate: healthCertificate,
			valueSets: valueSets,
			acceptanceRules: acceptanceRules,
			invalidationRules: invalidationRules,
			acceptanceRuleParameter: acceptanceRuleParameter,
			invalidationRuleParameter: invalidationRuleParameter,
			completion: completion
		)
		
	}
	
	private func proceedWithRulesValidation(
		healthCertificate: HealthCertificate,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		acceptanceRuleParameter: ExternalParameter,
		invalidationRuleParameter: ExternalParameter,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 7. apply acceptance rules
		
		let acceptanceRulesResult = validationRulesAccess.applyValidationRules(
			acceptanceRules,
			to: healthCertificate.digitalCovidCertificate,
			// ToDo: Exchange fake
			filter: FilterParameter.fake(),
			externalRules: acceptanceRuleParameter
		)

		guard case let .success(acceptanceRulesValidations) = acceptanceRulesResult else {
			if case let .failure(error) = acceptanceRulesResult {
				Log.error("Could not validate acceptance rules.", log: .vaccination, error: error)
				completion(.failure(.ACCEPTANCE_RULE_VALIDATION_ERROR(error)))
			}
			return
		}
		
		Log.info("Successfully validated acceptance rules: \(private: acceptanceRulesValidations). Proceed with invalidation rules validation...", log: .vaccination)

		// 9. apply invalidation rules
		
		let invalidationRulesResult = validationRulesAccess.applyValidationRules(
			invalidationRules,
			to: healthCertificate.digitalCovidCertificate,
			// ToDo: Exchange fake
			filter: FilterParameter.fake(),
			externalRules: invalidationRuleParameter
		)

		guard case let .success(invalidationRulesValidations) = invalidationRulesResult else {
			if case let .failure(error) = invalidationRulesResult {
				Log.error("Could not validate invalidation rules.", log: .vaccination, error: error)
				completion(.failure(.INVALIDATION_RULE_VALIDATION_ERROR(error)))
			}
			return
		}
		
		Log.info("Successfully validated invalidation rules: \(private: invalidationRulesValidations). Proceed with combined rule validation...", log: .vaccination)

		let combinedRuleValidations = acceptanceRulesValidations + invalidationRulesValidations
		proceedWithRulesInterpretation(
			combinedRuleValidations: combinedRuleValidations,
			completion: completion
		)
		
	}
	
	private func proceedWithRulesInterpretation(
		combinedRuleValidations: [ValidationResult],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		if combinedRuleValidations.allSatisfy({ $0.result == .passed }) {
			// all rules has to be .passed
			Log.info("Successfully combined rules: \(private: combinedRuleValidations). Validation result is: validationPassed. Validation complete.", log: .vaccination)
			completion(.success(.validationPassed))
		} else if combinedRuleValidations.contains(where: { $0.result == .open }) &&
					!combinedRuleValidations.contains(where: { $0.result == .fail }) {
			// At least one rule should contain now .open and there is no .fail
			Log.info("Successfully combined rules: \(private: combinedRuleValidations). Validation result is: validationOpen. Validation complete.", log: .vaccination)
			completion(.success(.validationOpen(combinedRuleValidations)))
		} else {
			// At least one rule should contain now .fail
			Log.info("Successfully combined rules: \(private: combinedRuleValidations). Validation result is: validationFailed. Validation complete.", log: .vaccination)
			completion(.success(.validationFailed(combinedRuleValidations)))
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
					var error: HealthCertificateValidationError
					switch ruleType {
					case .acceptance:
						error = .ACCEPTANCE_RULE_CLIENT_ERROR
					case .invalidation:
						error = .INVALIDATION_RULE_CLIENT_ERROR
					}
					Log.error("Could not create strong self", log: .vaccination)
					completion(.failure(error))
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
	
	private func rulesDownloadingSuccessHandler(
		ruleType: HealthCertificateValidationRuleType,
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Successfully received \(ruleType) acceptance rules package. Proceed with eTag verification...", log: .vaccination)

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.", log: .vaccination)
			var error: HealthCertificateValidationError
			switch ruleType {
			case .acceptance:
				error = .ACCEPTANCE_RULE_JSON_ARCHIVE_ETAG_ERROR
			case .invalidation:
				error = .INVALIDATION_RULE_JSON_ARCHIVE_ETAG_ERROR
			}
			completion(.failure(error))
			return
		}
		Log.info("Successfully verified eTag. Proceed with package extraction...", log: .vaccination)
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.", log: .vaccination)
			var error: HealthCertificateValidationError
			switch ruleType {
			case .acceptance:
				error = .ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING
			case .invalidation:
				error = .INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING
			}
			completion(.failure(error))
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...", log: .vaccination)
		
		guard signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure", log: .vaccination)
			var error: HealthCertificateValidationError
			switch ruleType {
			case .acceptance:
				error = .ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
			case .invalidation:
				error = .INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID
			}
			completion(.failure(error))
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
				var error: HealthCertificateValidationError
				switch ruleType {
				case .acceptance:
					error = .ACCEPTANCE_RULE_VALIDATION_ERROR(validationError)
				case .invalidation:
					error = .INVALIDATION_RULE_VALIDATION_ERROR(validationError)
				}
				Log.error("Could not decode CBOR from package with error:", log: .vaccination, error: error)
				completion(.failure(error))
			}
		})
	}
	
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
				var error: HealthCertificateValidationError
				switch ruleType {
				case .acceptance:
					error = .ACCEPTANCE_RULE_CLIENT_ERROR
				case .invalidation:
					error = .ACCEPTANCE_RULE_CLIENT_ERROR
				}
				completion(.failure(error))
			default:
				Log.error("Could not download \(ruleType) rules due to server error with status code: \(statusCode).", log: .vaccination, error: failure)
				var error: HealthCertificateValidationError
				switch ruleType {
				case .acceptance:
					error = .ACCEPTANCE_RULE_SERVER_ERROR
				case .invalidation:
					error = .ACCEPTANCE_RULE_SERVER_ERROR
				}
				completion(.failure(error))
			}
		default:
			Log.error("Could not download \(ruleType) rules due to server error.", log: .vaccination, error: failure)
			var error: HealthCertificateValidationError
			switch ruleType {
			case .acceptance:
				error = .ACCEPTANCE_RULE_SERVER_ERROR
			case .invalidation:
				error = .ACCEPTANCE_RULE_SERVER_ERROR
			}
			completion(.failure(error))
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
	
	// MARK: - External rule parameters
	
	private func assembleAcceptanceExternalRuleParameters(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> ExternalParameter {

		// ToDo: Exchange fake
		
//		let mappedValueSets = mapValueSetsForExternalParameter(valueSet: valueSet)
//		let mappedCertificateType = mapForExternalParameter(healthCertificate.type)
//
//		let externalRuleParameter = ExternalParameter(
//			validationClock: validationClock,
//			valueSets: mappedValueSets,
//			countryCode: arrivalCountry,
//			exp: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.expirationTime),
//			iat: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.issuedAt),
//			certificationType: mappedCertificateType,
//			issueCountryCode: healthCertificate.cborWebTokenHeader.issuer
//		)
//
//		return externalRuleParameter

		return .fake()
	}
	
	private func assembleInvalidationExternalRuleParameters(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> ExternalParameter {

		// ToDo: Exchange fake

//
//		let mappedValueSets = mapValueSetsForExternalParameter(valueSet: valueSet)
//		let mappedCertificateType = mapForExternalParameter(healthCertificate.type)
//
//		let externalRuleParameter = ExternalParameter(
//			validationClock: validationClock,
//			valueSets: mappedValueSets,
//			countryCode: healthCertificate.cborWebTokenHeader.issuer,
//			exp: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.expirationTime),
//			iat: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.issuedAt),
//			certificationType: mappedCertificateType,
//			issueCountryCode: healthCertificate.cborWebTokenHeader.issuer
//		)
//
//		return externalRuleParameter

		return .fake()
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
	
	private var allCountryCodes: [String] {
		// This list of country codes comes from our techspec 1:1 as it is. Because we want to keep the copied format, we disable swiftlint here.
		// swiftlint:disable line_length
		// swiftlint:disable comma
		return ["AD","AE","AF","AG","AI","AL","AM","AO","AQ","AR","AS","AT","AU","AW","AX","AZ","BA","BB","BD","BE","BF","BG","BH","BI","BJ","BL","BM","BN","BO","BQ","BR","BS","BT","BV","BW","BY","BZ","CA","CC","CD","CF","CG","CH","CI","CK","CL","CM","CN","CO","CR","CU","CV","CW","CX","CY","CZ","DE","DJ","DK","DM","DO","DZ","EC","EE","EG","EH","ER","ES","ET","FI","FJ","FK","FM","FO","FR","GA","GB","GD","GE","GF","GG","GH","GI","GL","GM","GN","GP","GQ","GR","GS","GT","GU","GW","GY","HK","HM","HN","HR","HT","HU","ID","IE","IL","IM","IN","IO","IQ","IR","IS","IT","JE","JM","JO","JP","KE","KG","KH","KI","KM","KN","KP","KR","KW","KY","KZ","LA","LB","LC","LI","LK","LR","LS","LT","LU","LV","LY","MA","MC","MD","ME","MF","MG","MH","MK","ML","MM","MN","MO","MP","MQ","MR","MS","MT","MU","MV","MW","MX","MY","MZ","NA","NC","NE","NF","NG","NI","NL","NO","NP","NR","NU","NZ","OM","PA","PE","PF","PG","PH","PK","PL","PM","PN","PR","PS","PT","PW","PY","QA","RE","RO","RS","RU","RW","SA","SB","SC","SD","SE","SG","SH","SI","SJ","SK","SL","SM","SN","SO","SR","SS","ST","SV","SX","SY","SZ","TC","TD","TF","TG","TH","TJ","TK","TL","TM","TN","TO","TR","TT","TV","TW","TZ","UA","UG","UM","US","UY","UZ","VA","VC","VE","VG","VI","VN","VU","WF","WS","YE","YT","ZA","ZM","ZW"]
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
