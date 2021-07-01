////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

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
		
	}
		
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
	private let signatureVerifier: SignatureVerification

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
}
