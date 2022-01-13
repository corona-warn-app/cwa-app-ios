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
		let resource = ValidationOnboardedCountriesResource()
		
		restService.load(resource) { result in
			switch result {
			case let .success(validationOnboardedCountriesModel):
				completion(.success(validationOnboardedCountriesModel.countries))
			case let .failure(error):
				guard let customError = resource.customError(for: error) else {
					Log.error("Unhandled error \(error.localizedDescription)", log: .vaccination)
					return
				}
				completion(.failure(customError))
			}
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let restService: RestServiceProviding
	private let signatureVerifier: SignatureVerification
}
