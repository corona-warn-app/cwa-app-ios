////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

protocol HealthCertificateValidationOnboardedCountriesProviding {
	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	)
}

final class HealthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		restService: RestServiceProviding,
		signatureVerifier: SignatureVerification = SignatureVerifier()
	) {
		self.store = store
		self.restService = restService
		self.signatureVerifier = signatureVerifier
	}
	
	// MARK: - Protocol HealthCertificateValidationOnboardedCountriesProviding
	
	func onboardedCountries(
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		/*
		restService.validationOnboardedCountries(
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
		 */
		let validationOnboardedCountriesResource = ValidationOnboardedCountriesResource()
		
		restService.load(validationOnboardedCountriesResource) { [weak self] result in
			guard let self = self else {
				Log.error("Could not create strong self", log: .vaccination)
				completion(.failure(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
				return
			}
			
//			switch result {
//			case let .success(packageDownloadResponse):
//				self.processOnboardedCountriesResponse(
//					packageDownloadResponse: packageDownloadResponse,
//					completion: completion
//				)
//			case let .failure(error):
//				self.processOnboardedCountriesFailure(
//					error: error,
//					completion: completion
//				)
//			}
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let restService: RestServiceProviding
	private let signatureVerifier: SignatureVerification
	
	private func processOnboardedCountriesResponse(
		packageDownloadResponse: PackageDownloadResponse,
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
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
					completion(.failure(.ONBOARDED_COUNTRIES_DECODING_ERROR(error)))
				}
			}
		)
	}
	
	private func processOnboardedCountriesFailure(
		error: URLSession.Response.Failure,
		completion: @escaping (Result<[Country], ValidationOnboardedCountriesError>) -> Void
	) {
		switch error {
		case .notModified:
			// Normally we should have cached something before
			Log.info("Download new onboarded countries aborted due to not modified content. Taking cached countries.", log: .vaccination)
			if let cachedOnboardedCountries = store.validationOnboardedCountriesCache?.onboardedCountries {
				completion(.success(cachedOnboardedCountries))
			} else {
				// If not, return edge case error
				Log.error("Could not find cached countries but need some.", log: .vaccination)
				completion(.failure(.ONBOARDED_COUNTRIES_MISSING_CACHE))
			}
		case .noNetworkConnection:
			Log.error("Could not download onboarded countries due to no network.", log: .vaccination, error: error)
			completion(.failure(.ONBOARDED_COUNTRIES_NO_NETWORK))
		case .noResponse:
			Log.error("Could not download onboarded countries due to no response.", log: .vaccination, error: error)
			completion(.failure(.ONBOARDED_COUNTRIES_NO_NETWORK))
		case let .serverError(statusCode):
			switch statusCode {
			case 400...409:
				Log.error("Could not download onboarded countries due to client error with status code: \(statusCode).", log: .vaccination, error: error)
				completion(.failure(.ONBOARDED_COUNTRIES_CLIENT_ERROR))
			default:
				Log.error("Could not download onboarded countries due to server error with status code: \(statusCode).", log: .vaccination, error: error)
				completion(.failure(.ONBOARDED_COUNTRIES_SERVER_ERROR))
			}
		default:
			Log.error("Could not download onboarded countries due to server error.", log: .vaccination, error: error)
			completion(.failure(.ONBOARDED_COUNTRIES_SERVER_ERROR))
		}
	}
	
	/// Extracts by the HealthCertificateToolkit the list of countrys. Expects the list as CBOR-Data and return for success the list of Country-Objects.
	private func extractCountryCodes(
		cborData: Data,
		completion: (Result<[Country], RuleValidationError>
		) -> Void
	) {
		let extractOnboardedCountryCodesResult = OnboardedCountriesAccess().extractCountryCodes(from: cborData)
		
		switch extractOnboardedCountryCodesResult {
		case let .success(countryCodes):
			let countries = countryCodes.compactMap {
				Country(withCountryCodeFallback: $0)
			}
			completion(.success(countries))
		case let .failure(error):
			completion(.failure(error))
		}
	}
}
