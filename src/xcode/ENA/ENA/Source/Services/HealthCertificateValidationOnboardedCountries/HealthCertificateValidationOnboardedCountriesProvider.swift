////
// 🦠 Corona-Warn-App
//

import Foundation
import HealthCertificateToolkit

protocol HealthCertificateValidationOnboardedCountriesProviding {
	func onboardedCountries(
		completion: @escaping (Result<[Country], ServiceError<ValidationOnboardedCountriesError>>) -> Void
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
		completion: @escaping (Result<[Country], ServiceError<ValidationOnboardedCountriesError>>) -> Void
	) {
		let validationOnboardedCountriesResource = ValidationOnboardedCountriesResource()
		
		restService.load(validationOnboardedCountriesResource) { result in
			switch result {
			case let .success(validationOnboardedCountriesModel):
				completion(.success(validationOnboardedCountriesModel.countries))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let restService: RestServiceProviding
	private let signatureVerifier: SignatureVerification
}
