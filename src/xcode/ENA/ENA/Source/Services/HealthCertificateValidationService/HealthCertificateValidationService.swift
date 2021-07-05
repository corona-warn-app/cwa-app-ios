////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit
// Do not import everything, just the datatypes we need to make a clean cut.
import class CertLogic.Rule
import class CertLogic.ExternalParameter
import enum CertLogic.CertificateType
import class CertLogic.ValidationResult

protocol HealthCertificateValidationProviding {
	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
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
final class HealthCertificateValidationService: HealthCertificateValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		vaccinationValueSetsProvider: VaccinationValueSetsProvider,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.store = store
		self.client = client
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.signatureVerifier = signatureVerifier
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol DCCValidationProviding
	
	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		client.validationOnboardedCountries(
			eTag: store.validationOnboardedCountriesCache?.lastOnboardedCountriesETag,
			isFake: false,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self")
					completion(.failure(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.onboardedCountriesSuccessHandler(
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
				case let .failure(error):
					self.onboardedCountriesFailureHandler(
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
			return completion(.failure(.TECHNICAL_VALIDATION_FAILED))
		}

		proceedWithUpdatingValueSets(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			completion: completion
		)

	}

	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	private let signatureVerifier: SignatureVerification
	
	private var subscriptions = Set<AnyCancellable>()
	
	// MARK: - Onboarded Countries
	
	private func onboardedCountriesSuccessHandler(
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		Log.info("Successfully received onboarded countries package. Proceed with eTag verification...")

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.")
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		
		Log.info("Successfully verified eTag. Proceed with package extraction...")
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.")
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_FILE_MISSING))
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...")
		
		guard self.signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure")
			completion(.failure(.ONBOARDED_COUNTRIES_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		Log.info("Successfully verified sapDownloadedPackage. Proceed now with CBOR decoding...")
		
		self.countryCodes(
			cborData: sapDownloadedPackage.bin,
			completion: { result in
				switch result {
				case let .success(countries):
					Log.info("Successfully decoded country codes. Returning now.")
					// Save in success case for caching
					let receivedOnboardedCountries = ValidationOnboardedCountriesCache(
						onboardedCountries: countries,
						lastOnboardedCountriesETag: eTag
					)
					store.validationOnboardedCountriesCache = receivedOnboardedCountries
					completion(.success(countries))
				case let .failure(error):
					Log.error("Could not decode CBOR from package with error:", error: error)
					completion(.failure(error))
				}
			}
		)
	}
	
	private func onboardedCountriesFailureHandler(
		error: URLSession.Response.Failure,
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
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
	private func countryCodes(
		cborData: Data,
		completion: (Result<[Country], ValidationOnboardedCountriesError>
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
	
	// MARK: - Validation
	
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
								completion(.failure(.VALUE_SET_SERVER_ERROR))
							default:
								Log.error("Unhandled Status Code while fetching certificate value sets", log: .vaccination, error: error)
							}
							
						} else if case URLSession.Response.Failure.noNetworkConnection = error {
							completion(.failure(.NO_NETWORK))
						}
					}
					
				}, receiveValue: { [weak self] valueSets in
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
		downloadAcceptanceRule(
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(acceptanceRules):
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
		downloadInvalidationRule(
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(invalidationRules):
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
		let acceptanceRuleParameter = self.assembleAcceptanceExternalRuleParameters(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			valueSet: valueSets
		)
		
		// 8. assemble external rule params for invalidation rules
		let invalidationRuleParameter = self.assembleInvalidationExternalRuleParameters(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			valueSet: valueSets
		)
		
		proceedWithRuleValidation(
			healthCertificate: healthCertificate,
			valueSets: valueSets,
			acceptanceRules: acceptanceRules,
			invalidationRules: invalidationRules,
			acceptanceRuleParameter: acceptanceRuleParameter,
			invalidationRuleParameter: invalidationRuleParameter,
			completion: completion
		)
		
	}
	
	private func proceedWithRuleValidation(
		healthCertificate: HealthCertificate,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		invalidationRules: [Rule],
		acceptanceRuleParameter: ExternalParameter,
		invalidationRuleParameter: ExternalParameter,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 7. apply acceptance rules
		
		let acceptanceRulesResult = ValidationRulesAccess().applyValidationRules(
			acceptanceRules,
			to: healthCertificate.digitalCovidCertificate,
			externalRules: acceptanceRuleParameter
		)

		guard case let .success(acceptanceRulesValidations) = acceptanceRulesResult else {
			if case let .failure(error) = acceptanceRulesResult {
				completion(.failure(.ACCEPTANCE_RULE_VALIDATION_ERROR(error)))
			}
			return
		}

		// 9. apply invalidation rules
		
		let invalidationRulesResult = ValidationRulesAccess().applyValidationRules(
			invalidationRules,
			to: healthCertificate.digitalCovidCertificate,
			externalRules: invalidationRuleParameter
		)

		guard case let .success(invalidationRulesValidations) = invalidationRulesResult else {
			if case let .failure(error) = invalidationRulesResult {
				completion(.failure(.INVALIDATION_RULE_VALIDATION_ERROR(error)))
			}
			return
		}

		let combinedRuleValidations = acceptanceRulesValidations + invalidationRulesValidations
		proceedWithRuleInterpretation(
			combinedRuleValidations: combinedRuleValidations,
			completion: completion
		)
		
	}
	
	private func proceedWithRuleInterpretation(
		combinedRuleValidations: [ValidationResult],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// if one rule contains .fail, we call this with the corresponding rules:
		guard combinedRuleValidations.contains( where: { $0.result == .fail }) else {
			// TODO: Do we return all results or only the open and failed ones?
			completion(.success(.validationFailed(combinedRuleValidations)))
			return
		}
		
		// if all rules contains .open, we call this with the corresponding rules:
		guard combinedRuleValidations.allSatisfy({ $0.result == .open }) else {
			// TODO: Do we return all results or only the open ones?
			completion(.success(.validationOpen(combinedRuleValidations)))
			return
		}
		
		// At this point, every rule should be passed, so we can call the best success.
		// if all rules contains .passed, we call this:
		completion(.success(.validationPassed))
	}
		
	private func downloadAcceptanceRule(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		client.getDCCRules(
			eTag: store.acceptanceRulesCache?.lastValidationRulesETag,
			isFake: false,
			ruleType: .acceptance,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self")
					completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.acceptanceRuleDownloadingSuccessHandler(
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
	
				case let .failure(error):
					self.acceptanceRuleDownloadingFailureHandler(
						error: error,
						completion: completion
					)
				}
			}
		)
	}
	
	private func acceptanceRuleDownloadingSuccessHandler(
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Successfully received acceptance rules package. Proceed with eTag verification...")

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.")
			completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		
		Log.info("Successfully verified eTag. Proceed with package extraction...")
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.")
			completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_FILE_MISSING))
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...")
		
		guard self.signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure")
			completion(.failure(.ACCEPTANCE_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		Log.info("Successfully verified sapDownloadedPackage. Proceed now with CBOR decoding...")
		
		
		self.acceptanceRules(sapDownloadedPackage.bin, completion: { result in
			switch result {
			case let .success(acceptanceRules):
				Log.info("Successfully decoded acceptance rules. Returning now.")
				// Save in success case for caching
				let receivedAcceptanceRules = ValidationRulesCache(
					validationRules: acceptanceRules,
					lastValidationRulesETag: eTag
				)
				store.acceptanceRulesCache = receivedAcceptanceRules
				completion(.success(acceptanceRules))
			case let .failure(error):
				Log.error("Could not decode CBOR from package with error:", error: error)
				completion(.failure(error))
			}
		})
	}
	
	private func acceptanceRuleDownloadingFailureHandler(
		error: URLSession.Response.Failure,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		switch error {
		case .notModified:
			// Normally we should have cached something before
			if let cachedAcceptanceRules = store.acceptanceRulesCache?.validationRules {
				completion(.success(cachedAcceptanceRules))
			} else {
				// If not, return edge case error
				completion(.failure(.ACCEPTANCE_RULE_MISSING_CACHE))
			}
		case .noNetworkConnection:
			completion(.failure(.NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
			default:
				completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
			}
		default:
			completion(.failure(.ACCEPTANCE_RULE_SERVER_ERROR))
		}
	}
	
	private func acceptanceRules(_ data: Data, completion: (Result<[Rule], HealthCertificateValidationError>) -> Void) {
		let extractAcceptanceRulesResult = ValidationRulesAccess().extractValidationRules(from: data)
		
		switch extractAcceptanceRulesResult {
		case let .success(acceptanceRules):
			completion(.success(acceptanceRules))
		case .failure:
			completion(.failure(.ACCEPTANCE_RULE_JSON_DECODING_FAILED))
		}
	}
	
	// MARK: - Invalidation Rules
	
	private func downloadInvalidationRule(
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		client.getDCCRules(
			eTag: store.invalidationRulesCache?.lastValidationRulesETag,
			isFake: false,
			ruleType: .invalidation,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self")
					completion(.failure(.INVALIDATION_RULE_CLIENT_ERROR))
					return
				}
				
				switch result {
				case let .success(packageDownloadResponse):
					self.invalidationRuleDownloadingSuccessHandler(
						packageDownloadResponse: packageDownloadResponse,
						completion: completion
					)
	
				case let .failure(error):
					self.invalidationRuleDownloadingFailureHandler(
						error: error,
						completion: completion
					)
				}
			}
		)
	}
	
	private func invalidationRuleDownloadingSuccessHandler(
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		Log.info("Successfully received invalidation rules package. Proceed with eTag verification...")

		guard let eTag = packageDownloadResponse.etag else {
			Log.error("ETag of package is missing. Return with failure.")
			completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		
		Log.info("Successfully verified eTag. Proceed with package extraction...")
				
		guard !packageDownloadResponse.isEmpty,
			  let sapDownloadedPackage = packageDownloadResponse.package else {
			Log.error("PackageDownloadResponse is empty. Return with failure.")
			completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_FILE_MISSING))
			return
		}
		Log.info("Successfully extracted sapDownloadedPackage. Proceed with package verification...")
		
		guard self.signatureVerifier.verify(sapDownloadedPackage) else {
			Log.error("Verification of sapDownloadedPackage failed. Return with failure")
			completion(.failure(.INVALIDATION_RULE_JSON_ARCHIVE_SIGNATURE_INVALID))
			return
		}
		Log.info("Successfully verified sapDownloadedPackage. Proceed now with CBOR decoding...")
		
		
		self.acceptanceRules(sapDownloadedPackage.bin, completion: { result in
			switch result {
			case let .success(invalidationRules):
				Log.info("Successfully decoded acceptance rules. Returning now.")
				// Save in success case for caching
				let receivedInvalidationRules = ValidationRulesCache(
					validationRules: invalidationRules,
					lastValidationRulesETag: eTag
				)
				store.invalidationRulesCache = receivedInvalidationRules
				completion(.success(invalidationRules))
			case let .failure(error):
				Log.error("Could not decode CBOR from package with error:", error: error)
				completion(.failure(error))
			}
		})
	}
	
	private func invalidationRuleDownloadingFailureHandler(
		error: URLSession.Response.Failure,
		completion: @escaping (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		switch error {
		case .notModified:
			// Normally we should have cached something before
			if let cachedInvalidationRules = store.invalidationRulesCache?.validationRules {
				completion(.success(cachedInvalidationRules))
			} else {
				// If not, return edge case error
				completion(.failure(.INVALIDATION_RULE_MISSING_CACHE))
			}
		case .noNetworkConnection:
			completion(.failure(.NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				completion(.failure(.INVALIDATION_RULE_CLIENT_ERROR))
			default:
				completion(.failure(.INVALIDATION_RULE_SERVER_ERROR))
			}
		default:
			completion(.failure(.INVALIDATION_RULE_SERVER_ERROR))
		}
	}
	
	private func invalidationRules(_ data: Data, completion: (Result<[Rule], HealthCertificateValidationError>) -> Void) {
		let extractInvalidationRulesResult = ValidationRulesAccess().extractValidationRules(from: data)
		
		switch extractInvalidationRulesResult {
		case let .success(invalidationRules):
			completion(.success(invalidationRules))
		case .failure:
			completion(.failure(.INVALIDATION_RULE_JSON_DECODING_FAILED))
		}
	}
	
	// MARK: - External rule parameters
	
	private func assembleAcceptanceExternalRuleParameters(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> ExternalParameter {
		
		let mappedValueSets = mapValueSetsForExternalParameter(valueSet: valueSet)
		let mappedCertificateType = mapForExternalParameter(healthCertificate.type)
		
		let externalRuleParameter = ExternalParameter(
			validationClock: validationClock,
			valueSets: mappedValueSets,
			countryCode: arrivalCountry,
			exp: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.expirationTime),
			iat: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.issuedAt),
			certificationType: mappedCertificateType,
			issueCountryCode: healthCertificate.cborWebTokenHeader.issuer
		)
		
		return externalRuleParameter
	}
	
	private func assembleInvalidationExternalRuleParameters(
		healthCertificate: HealthCertificate,
		arrivalCountry: String,
		validationClock: Date,
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> ExternalParameter {
		
		let mappedValueSets = mapValueSetsForExternalParameter(valueSet: valueSet)
		let mappedCertificateType = mapForExternalParameter(healthCertificate.type)

		let externalRuleParameter = ExternalParameter(
			validationClock: validationClock,
			valueSets: mappedValueSets,
			countryCode: healthCertificate.cborWebTokenHeader.issuer,
			exp: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.expirationTime),
			iat: mapUnixTimestampsInSecondsToDate(healthCertificate.cborWebTokenHeader.issuedAt),
			certificationType: mappedCertificateType,
			issueCountryCode: healthCertificate.cborWebTokenHeader.issuer
		)
		
		return externalRuleParameter
	}
	
	/// Maps our valueSet on the value set of CertLogic. See https://github.com/corona-warn-app/cwa-app-tech-spec/blob/proposal/business-rules-dcc/docs/spec/dgc-validation-rules-client.md#data-structure-of-external-rule-parameters
	private func mapValueSetsForExternalParameter(
		valueSet: SAP_Internal_Dgc_ValueSets
	) -> [String: [String]] {
		var dictionary = [String: [String]]()
		dictionary["country-2-codes"] = allCountryCodes
		dictionary["covid-19-lab-result"] = valueSet.tcTr.items.map { $0.key }
		dictionary["covid-19-lab-test-manufacturer-and-name"] = valueSet.ma.items.map { $0.key }
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
			return .vacctination
		case .test:
			return .test
		case .recovery:
			return .recovery
		}
	}
	
	private func mapUnixTimestampsInSecondsToDate(_ timestamp: UInt64?) -> Date {
		guard let timestamp = timestamp else {
			// TODO: What should we do here?
			fatalError("This should not happen")
		}
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}
