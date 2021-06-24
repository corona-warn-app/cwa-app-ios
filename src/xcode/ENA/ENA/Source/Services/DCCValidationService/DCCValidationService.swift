////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol DCCValidationProviding {
	func validateDcc(
		dcc: String,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Int,
		cborWebToken: String,
		completion: @escaping (Result<DCCValidationProgress, DCCValidationError>) -> Void
	)
}

final class DCCValidationService: DCCValidationProviding {
	
	// MARK: - Init
	
	init(
	
	) {
		
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol DCCValidationProviding
	
	func validateDcc(
		dcc: String,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Int,
		cborWebToken: String,
		completion: @escaping (Result<DCCValidationProgress, DCCValidationError>) -> Void
	) {
		
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
}
