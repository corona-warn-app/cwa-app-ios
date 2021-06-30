////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol DCCValidationProviding {
	func onboardedCountries(
		completion: @escaping (Result<[Country], DCCOnboardedCountriesError>) -> Void
	)
	
	func validateDcc(
		dcc: DigitalGreenCertificate,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Date,
		cborWebToken: CBORWebTokenHeader,
		completion: @escaping (Result<DCCValidationReport, DCCValidationError>) -> Void
	)
}

final class DCCValidationService: DCCValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client
	) {
		self.store = store
		self.client = client
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol DCCValidationProviding
	
	func onboardedCountries(
		completion: @escaping (Result<[Country], DCCOnboardedCountriesError>) -> Void
	) {
		
	}
	
	func validateDcc(
		dcc: DigitalGreenCertificate,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Date,
		cborWebToken: CBORWebTokenHeader,
		completion: @escaping (Result<DCCValidationReport, DCCValidationError>) -> Void
	) {
		
	}
		
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let store: Store
	private let client: Client
		
}
