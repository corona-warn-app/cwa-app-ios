////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit
// Do not import everything, just the datatypes we need to make a clean cut.
import class CertLogic.Rule

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

final class HealthCertificateValidationService: HealthCertificateValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.store = store
		self.client = client
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
		
//		applyTechnicalValidation(validationClock: validationClock, expirationDate: <#T##Date#>)
//		
//		switch result {
//		case let .failure(progress):
//			completion(.failure(progress))
//			
//		case let .success(progress):
//			
//			// 2. update/ download value sets
//			updateValueSets(
//				completion: { result in
//					switch result {
//					case let .failure(error):
//						completion(.failure(error))
//					case let .success(valueSets):
//						
//						downloadAcceptanceRules()
//						
//						break
//		
//					}
//				})
//		}

		// 3. update/ download acceptance rules
		
		// 4. update/ download invalidation rules
		
		// 5. assemble external rule params
		
		// 6. assemble external rule params for acceptance rules
		
		// 7. apply acceptance rules
		
		// 8. assemble external rule params for invalidation rules
		
		// 9. apply invalidation rules

	}
		
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private let signatureVerifier: SignatureVerification
	
	private var subscriptions = Set<AnyCancellable>()
	
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
		
		self.countryCodes(sapDownloadedPackage.bin, completion: { result in
			switch result {
			case let .success(countries):
				Log.info("Successfully decoded country codes. Returning now.")
				// Save in success case for caching
				let receivedOnboardedCountries = ValidationOnboardedCountriesCache(
					onboardedCountries: countries,
					lastOnboardedCountriesETag: eTag)
				store.validationOnboardedCountriesCache = receivedOnboardedCountries
				completion(.success(countries))
			case let .failure(error):
				Log.error("Could not decode CBOR from package with error:", error: error)
				completion(.failure(error))
			}
		})
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
	private func countryCodes(_ data: Data, completion: (Result<[Country], ValidationOnboardedCountriesError>) -> Void) {
		let extractOnboardedCountryCodesResult = OnboardedCountriesAccess().extractCountryCodes(from: data)
		
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
	
	// MARK: - 1. Apply technical validation
	
	private func applyTechnicalValidation(
		validationClock: Date,
		expirationDate: Date
	) -> Result<DCCValidationReport, DCCValidationError> {
		// JsonSchemaCheck is always true because we expect here a DigitalGreenCertificate, which was already json schema validated at its creation.
		var progress = DCCValidationReport(
			expirationCheck: false,
			jsonSchemaCheck: true,
			acceptanceRuleValidation: nil,
			invalidationRuleValidation: nil
		)
		
		// Check expiration date
		guard expirationDate >= validationClock else {
			return .failure(DCCValidationError.TECHNICAL_VALIDATION_FAILED(progress))
		}
		progress.expirationCheck = true
		
		return .success(progress)
	}
	
	// MARK: - 2. Update/ download value sets
	
	private func updateValueSets(
		completion: @escaping (Result<SAP_Internal_Dgc_ValueSets, DCCValidationError>) -> Void
	) {
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
					
				}, receiveValue: { valueSets in
					completion(.success(valueSets))
				}
			)
			.store(in: &subscriptions)
	}
	
	// MARK: - 3. Update/ download acceptance rules
	
	private func downloadAcceptanceRule(
		completion: (Result<[Rule], DCCValidationError>) -> Void
	) {
		client.getDCCRules(
			eTag: store.acceptanceRulesCache?.lastValidationRulesETag,
			isFake: false,
			ruleType: .acceptance,
			completion: { [weak self] result in
				guard let self = self else {
					Log.error("Could not create strong self")
					// completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR(<#T##DCCValidationReport#>)))
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
	
	// MARK: - 4. Update/ download invalidation rules
	
	// MARK: - 5. Assemble external rule parameters
	
	// MARK: - 6. Assemble external rule parameters for acceptance rules
	
	// MARK: - 7. Apply acceptance rules
	
	// MARK: - 8. Assemble external rule parameter for invalidation rules
	
	// MARK: - 9. Apply invalidation rules
}
