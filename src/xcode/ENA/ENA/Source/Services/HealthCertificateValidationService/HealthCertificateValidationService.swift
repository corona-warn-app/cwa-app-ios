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
				

		// 2. update/ download value sets
		updateValueSets(
			completion: { result in
				switch result {
				case let .failure(error):
					completion(.failure(error))
				case let .success(valueSets):
					break
					
				}
			}
		)
	}


		// 3. update/ download acceptance rules
		
		// 4. update/ download invalidation rules
		
		// 5. assemble external rule params
		
		// 6. assemble external rule params for acceptance rules
		
		// 7. apply acceptance rules
		
		// 8. assemble external rule params for invalidation rules
		
		// 9. apply invalidation rules

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
		
		self.countryCodes(sapDownloadedPackage.bin, completion: { result in
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
	
	// MARK: - Rule Validation
	
	private func updateValueSets(
		completion: @escaping (Result<SAP_Internal_Dgc_ValueSets, HealthCertificateValidationError>) -> Void
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
	
	private func downloadAcceptanceRule(
		completion: (Result<[Rule], HealthCertificateValidationError>) -> Void
	) {
		
		client.getDCCRules(
			eTag: store.acceptanceRulesCache?.lastValidationRulesETag,
			isFake: false,
			ruleType: .acceptance,
			completion: { result in
				switch result {
				case let .success(packageDownloadResponse):
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
					
					
					self.acceptanceRules(sapDownloadedPackage.bin, completion: { [weak self] result in
						switch result {
						case let .success(acceptanceRules):
							
							guard let self = self else {
								Log.error("Could not create strong self")
								completion(.failure(.ACCEPTANCE_RULE_CLIENT_ERROR))
								return
							}
							
							Log.info("Successfully decoded acceptance rules. Returning now.")
							// Save in success case for caching
							let receivedAcceptanceRules = ValidationRulesCache(
								validationRules: acceptanceRules,
								lastValidationRulesETag: eTag
							)
							self.store.acceptanceRulesCache = receivedAcceptanceRules
							completion(.success(acceptanceRules))
						case let .failure(error):
							Log.error("Could not decode CBOR from package with error:", error: error)
							completion(.failure(error))
						}
					})
				case let .failure(error):
					break
				}
			}
		)
	}
	
	/// Extracts by the HealthCertificateToolkit the list of countrys. Expects the list as CBOR-Data and return for success the list of Country-Objects.
	private func acceptanceRules(_ data: Data, completion: (Result<[Rule], HealthCertificateValidationError>) -> Void) {
		let extractAcceptanceRulesResult = ValidationRulesAccess().extractValidationRules(from: data)
		
		switch extractAcceptanceRulesResult {
		case let .success(acceptanceRules):
			completion(.success(acceptanceRules))
		case .failure:
			completion(.failure(.ACCEPTANCE_RULE_JSON_DECODING_FAILED))
		}
	}
	
	// MARK: - 4. Update/ download invalidation rules
	
	// MARK: - 5. Assemble external rule parameters
	
	// MARK: - 6. Assemble external rule parameters for acceptance rules
	
	// MARK: - 7. Apply acceptance rules
	
	// MARK: - 8. Assemble external rule parameter for invalidation rules
	
	// MARK: - 9. Apply invalidation rules
}
