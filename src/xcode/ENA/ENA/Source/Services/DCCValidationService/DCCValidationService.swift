////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol DCCValidationProviding {
	func validateDcc(
		dcc: DigitalGreenCertificate,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Date,
		cborWebToken: CBORWebTokenHeader,
		completion: @escaping (Result<DCCValidationProgress, DCCValidationError>) -> Void
	)
}

final class DCCValidationService: DCCValidationProviding {
	
	// MARK: - Init
	
	init(
		vaccinationValueSetsProvider: VaccinationValueSetsProvider
	) {
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol DCCValidationProviding
	
	func validateDcc(
		dcc: DigitalGreenCertificate,
		issuerCountry: String,
		arrivalCountry: String,
		validationClock: Date,
		cborWebToken: CBORWebTokenHeader,
		completion: @escaping (Result<DCCValidationProgress, DCCValidationError>) -> Void
	) {
		
		// 1. Apply technical validation
		
		let expirationDate = Date(timeIntervalSince1970: TimeInterval(cborWebToken.expirationTime))
		let result = applyTechnicalValidation(validationClock: validationClock, expirationDate: expirationDate)
		
		switch result {
		case let .failure(progress):
			completion(.failure(progress))
			
		case let .success(progress):
			break
		}
		
		// 2. update/ download value sets
		
		
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
	
	private let vaccinationValueSetsProvider: VaccinationValueSetsProvider
	
	private func applyTechnicalValidation(
		validationClock: Date,
		expirationDate: Date
	) -> Result<DCCValidationProgress, DCCValidationError> {
		
		// JsonSchemaCheck is always true because we expect here a DigitalGreenCertificate, wich was already json schema validated at its creation.
		var progress = DCCValidationProgress(
			expirationCheck: false,
			jsonSchemaCheck: true,
			acceptanceRuleValidation: nil,
			invalidationRuleValidation: nil
		)
		
		// Check expiration date
		guard expirationDate <= validationClock else {
			return .failure(DCCValidationError.TECHNICAL_VALIDATION_FAILED(progress))
		}
		progress.expirationCheck = true
		
		return .success(progress)
	}
	
	private func updateValueSets(
	
	) {
		
		vaccinationValueSetsProvider.latestVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case CachingHTTPClient.CacheError.dataVerificationError = error {
							Log.error("Signature verification error.", log: .vaccination, error: error)
						}
						Log.error("Could not fetch Vaccination value sets protobuf.", log: .vaccination, error: error)
					}
				}, receiveValue: { [weak self] valueSets in
					self?.valueSets = valueSets
					self?.updateHealthCertificateKeyValueCellViewModels()
				}
			)
			.store(in: &subscriptions)
	}
	
}
