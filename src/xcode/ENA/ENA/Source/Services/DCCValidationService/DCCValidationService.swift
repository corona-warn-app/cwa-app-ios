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
			
			// 2. update/ download value sets
			updateValueSets(
				completion: { result in
					switch result {
					case let .failure(error):
						completion(.failure(error))
					case let .success(valueSets):
						
						// reminder: Caching of the onboarded countries list
						break
		
					}
				})
		}

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
	
	private var subscriptions = Set<AnyCancellable>()
	
	private func applyTechnicalValidation(
		validationClock: Date,
		expirationDate: Date
	) -> Result<DCCValidationProgress, DCCValidationError> {
		
		// JsonSchemaCheck is always true because we expect here a DigitalGreenCertificate, which was already json schema validated at its creation.
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
	
}
