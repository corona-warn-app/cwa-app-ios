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
		arrivalCountry: Country,
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

final class HealthCertificateValidationService: HealthCertificateValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		validationRulesAccess: ValidationRulesAccessing = ValidationRulesAccess(),
		dccSignatureVerifier: DCCSignatureVerifying,
		dscListProvider: DSCListProviding,
		rulesDownloadService: RulesDownloadServiceProviding
	) {
		self.store = store
		self.client = client
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.dccSignatureVerifier = dccSignatureVerifier
 		self.validationRulesAccess = validationRulesAccess
		self.dscListProvider = dscListProvider
		self.rulesDownloadService = rulesDownloadService
	}
		
	// MARK: - Protocol HealthCertificateValidationProviding
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 1. Apply technical validation
		
		let signatureInvalid: Bool
		var signatureValidationError: Error?
		
		let result = dccSignatureVerifier.verify(
			certificate: healthCertificate.base45,
			with: dscListProvider.signingCertificates.value,
			and: validationClock
		)
		switch result {
		case .success:
			signatureInvalid = false
		case.failure(let error):
			signatureInvalid = true
			signatureValidationError = error
		}
		
		let expirationDate = healthCertificate.cborWebTokenHeader.expirationTime
		// NOTE: We expect here a HealthCertificate, which was already json schema validated at its creation time. So the JsonSchemaCheck will here always be true. So we only have to check for the expirationTime of the certificate.
		let isExpired = expirationDate < validationClock
		
		guard !isExpired && !signatureInvalid else {
			if signatureInvalid {
				Log.warning("Technical validation failed: signature invalid. Error: \(signatureValidationError?.localizedDescription ?? "-")", log: .vaccination)
			}
			if isExpired {
				Log.warning("Technical validation failed: expirationDate < validationClock. Expiration date: \(private: expirationDate), validationClock: \(private: validationClock)", log: .vaccination)
			}
			completion(.failure(.TECHNICAL_VALIDATION_FAILED(expirationDate: isExpired ? expirationDate : nil, signatureInvalid: signatureInvalid)))
			return
		}
		Log.info("Successfully passed signature verification and technical validation. Proceed with updating value sets...", log: .vaccination)

		updateValueSets(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			completion: completion
		)
	}
	
	// MARK: - Private
	
	private let rulesDownloadService: RulesDownloadServiceProviding
	private let store: Store
	private let client: Client
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let validationRulesAccess: ValidationRulesAccessing
	private let dccSignatureVerifier: DCCSignatureVerifying
	private let dscListProvider: DSCListProviding
	private var subscriptions = Set<AnyCancellable>()
	
	// MARK: - Flow
	
	private func updateValueSets(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 2. update/ download value sets
		vaccinationValueSetsProvider.fetchVaccinationCertificateValueSets()
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
							completion(.failure(.downloadRulesError(.NO_NETWORK)))
						} else {
							Log.error("Casting error for http error failed", log: .vaccination, error: error)
							completion(.failure(.VALUE_SET_CLIENT_ERROR))
						}
					}
				}, receiveValue: { [weak self] valueSets in
					guard let self = self else { return }

					Log.info("Successfully received value sets. Proceed with downloading acceptance rules...", log: .vaccination)
					self.prepareAndDownloadValidationRules(
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
	
	// Validation Rules Preparation
	
	func prepareAndDownloadValidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 1. update/ download acceptance rules
		self.rulesDownloadService.downloadRules(
			ruleType: .acceptance,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(.downloadRulesError(error)))
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
	
	private func downloadInvalidationRules(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		valueSets: SAP_Internal_Dgc_ValueSets,
		acceptanceRules: [Rule],
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 2. update/ download invalidation rules
		self.rulesDownloadService.downloadRules(
			ruleType: .invalidation,
			completion: { [weak self] result in
				switch result {
				case let .failure(error):
					completion(.failure(.downloadRulesError(error)))
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
	
	// Internal for testing purposes
	func mapUnixTimestampsInSecondsToDate(_ timestamp: UInt64) -> Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}
