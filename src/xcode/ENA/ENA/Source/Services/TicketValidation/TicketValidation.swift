//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct ServiceIdentityRequestResult {
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: [JSONWebKey]
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: [JSONWebKey]
	let validationServiceSignKeyJwkSet: [JSONWebKey]
}

enum ServiceIdentityRequestError: Error {
	case VS_ID_NO_ENC_KEY
	case VS_ID_NO_SIGN_KEY
	case VS_ID_EMPTY_X5C
	case REST_SERVICE_ERROR(ServiceError<ServiceIdentityDocumentResourceError>)
	case UNKOWN
}

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData,
		restServiceProvider: RestServiceProviding,
		serviceIdentityProcessor: TicketValidationServiceIdentityDocumentProcessing
	) {
		self.initializationData = initializationData
		self.restServiceProvider = restServiceProvider
		self.serviceIdentityProcessor = serviceIdentityProcessor
	}

	var initializationData: TicketValidationInitializationData
	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {

	}

	func grantFirstConsent(
		completion: @escaping (Result<TicketValidationConditions, TicketValidationError>) -> Void
	) {

	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {

	}

	func validate(
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
	) {

	}

	func cancel() {

	}
	
	func requestServiceIdentityDocument(
		validationServiceData: TicketValidationServiceData,
		validationServiceJwkSet: [JSONWebKey],
		completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
	) {
		guard let url = URL(string: validationServiceData.serviceEndpoint) else {
			completion(.failure(.UNKOWN))
			return
		}
		
		let resource = ServiceIdentityDocumentResource(endpointUrl: url)
		
		restServiceProvider.load(resource) { [weak self] result in
			switch result {
			case .success(let serviceIdentityDocument):
				self?.serviceIdentityProcessor.process(
					validationServiceJwkSet: validationServiceJwkSet,
					serviceIdentityDocument: serviceIdentityDocument,
					completion: completion
				)
			case .failure(let error):
				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}

	func validateIdentityDocumentOfValidationDecorator(
		urlString: String,
		completion:
		@escaping (Result<TicketValidationServiceIdentityDocumentValidationDecorator, ServiceIdentityValidationDecoratorError>) -> Void
	) {
		guard let url = URL(string: urlString) else {
			Log.error("URL cant be constructed from input string", log: .ticketValidationDecorator)
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				TicketValidationDecoratorIdentityDocumentProcessor().validateIdentityDocument(serviceIdentityDocument: model) { result in
					completion(result)
				}
			case .failure(let error):
				completion(.failure(.REST_SERVICE_ERROR(error)))
				Log.error(error.localizedDescription, log: .ticketValidationDecorator)
			}
		}
	}
	
	// MARK: - Private
	private let serviceIdentityProcessor: TicketValidationServiceIdentityDocumentProcessing
	private let restServiceProvider: RestServiceProviding
}
