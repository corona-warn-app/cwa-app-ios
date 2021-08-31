////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import HealthCertificateToolkit

protocol HealthCertificateValidationProviding {
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	)
}

/*
General flow:
1. apply technical validation (expirationTimes)
2. download new certificate value sets or load them from the cache
3. download new acceptance rules or load them from the cache
4. download new invalidation rules or load them from the cache
5. assemble FilterParameter and ExternalParameter
6. validate combined acceptance and invalidation rules
7. return interpreted rules
*/

final class HealthCertificateValidationService: HealthCertificateValidationProviding {
	
	// MARK: - Init
	
	init(
		store: Store,
		client: Client,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		signatureVerifier: SignatureVerification = SignatureVerifier(),
		validationRulesAccess: ValidationRulesAccessing = ValidationRulesAccess(),
		signatureVerifying: DCCSignatureVerifying,
		dscListProvider: DSCListProviding
	) {
		self.store = store
		self.client = client
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.signatureVerifier = signatureVerifier
		self.validationRulesAccess = validationRulesAccess
		self.signatureVerifying = signatureVerifying
		self.dscListProvider = dscListProvider
	}
		
	// MARK: - Protocol HealthCertificateValidationProviding
	
	func validate(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		
		// 1. Apply technical validation
		
		let signatureInvalid: Bool
		var signatureValidationError: Error?
		
		let result = signatureVerifying.verify(
			certificate: healthCertificate.base45,
			with: dscListProvider.signingCertificates.value,
			and: validationClock
		)
		switch result {
		case .success:
			signatureInvalid = false
		case.failure(let error):
			signatureInvalid = true
			signatureValidationError = error
		}
		
		let expirationDate = healthCertificate.cborWebTokenHeader.expirationTime
		// NOTE: We expect here a HealthCertificate, which was already json schema validated at its creation time. So the JsonSchemaCheck will here always be true. So we only have to check for the expirationTime of the certificate.
		let isExpired = expirationDate < validationClock
		
		guard !isExpired && !signatureInvalid else {
			if signatureInvalid {
				Log.warning("Technical validation failed: signature invalid. Error: \(signatureValidationError?.localizedDescription ?? "-")", log: .vaccination)
			}
			if isExpired {
				Log.warning("Technical validation failed: expirationDate < validationClock. Expiration date: \(private: expirationDate), validationClock: \(private: validationClock)", log: .vaccination)
			}
			completion(.failure(.TECHNICAL_VALIDATION_FAILED(expirationDate: isExpired ? expirationDate : nil, signatureInvalid: signatureInvalid)))
			return
		}
		Log.info("Successfully passed signature verification and technical validation. Proceed with updating value sets...", log: .vaccination)

		updateValueSets(
			healthCertificate: healthCertificate,
			arrivalCountry: arrivalCountry,
			validationClock: validationClock,
			completion: completion
		)
	}
	
	// MARK: - Private
	
	private var rulesDownloadService: ValidationRulesDownloadServiceProviding?
	private let store: Store
	private let client: Client
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let signatureVerifier: SignatureVerification
	private let validationRulesAccess: ValidationRulesAccessing
	private let signatureVerifying: DCCSignatureVerifying
	private let dscListProvider: DSCListProviding
	private var subscriptions = Set<AnyCancellable>()
	
	// MARK: - Flow
	
	private func updateValueSets(
		healthCertificate: HealthCertificate,
		arrivalCountry: Country,
		validationClock: Date,
		completion: @escaping (Result<HealthCertificateValidationReport, HealthCertificateValidationError>) -> Void
	) {
		// 2. update/ download value sets
		vaccinationValueSetsProvider.fetchVaccinationCertificateValueSets()
			.sink(
				receiveCompletion: { result in
					switch result {
					case .finished:
						break
					case .failure(let error):
						if case let URLSession.Response.Failure.httpError(_, response) = error {
							switch response.statusCode {
							case 500...509:
								Log.error("Failed to update value sets with status code: \(response.statusCode)", log: .vaccination, error: error)
								completion(.failure(.VALUE_SET_SERVER_ERROR))
							default:
								Log.error("Unhandled Status Code while fetching certificate value sets", log: .vaccination, error: error)
								completion(.failure(.VALUE_SET_CLIENT_ERROR))
							}
							
						} else if case URLSession.Response.Failure.noNetworkConnection = error {
							Log.error("Failed to update value sets. No network error", log: .vaccination, error: error)
							completion(.failure(.NO_NETWORK))
						} else {
							Log.error("Casting error for http error failed", log: .vaccination, error: error)
							completion(.failure(.VALUE_SET_CLIENT_ERROR))
						}
					}
				}, receiveValue: { [weak self] valueSets in
					guard let self = self else { return }

					Log.info("Successfully received value sets. Proceed with downloading acceptance rules...", log: .vaccination)
					self.rulesDownloadService = RulesDownloadService(store: self.store, client: self.client)
						
					self.rulesDownloadService?.prepareAndDownloadValidationRules(
						healthCertificate: healthCertificate,
						arrivalCountry: arrivalCountry,
						validationClock: validationClock,
						valueSets: valueSets,
						completion: completion
					)
				}
			)
			.store(in: &subscriptions)
	}
	
	// Internal for testing purposes
	func mapUnixTimestampsInSecondsToDate(_ timestamp: UInt64) -> Date {
		return Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}
