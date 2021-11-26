//
// 🦠 Corona-Warn-App
//

import Foundation

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData,
		restServiceProvider: RestServiceProviding
	) {
		self.initializationData = initializationData
		self.restServiceProvider = restServiceProvider
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
	
	func validateIdentityDocumentOfValidationDecorator(
		urlString: String,
		completion:
		@escaping (Result<ServiceIdentityDocumentValidationDecorator, ServiceIdentityValidationDecoratorError>) -> Void
	) {
		guard let url = URL(string: urlString) else {
			Log.error("URL cant be constructed from input string", log: .ticketValidationDecorator)
			return
		}
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				TVDecoratorIdentityDocumentProcessor().validateIdentityDocument(serviceIdentityDocument: model) { result in
					completion(result)
				}
			case .failure(let error):
				completion(.failure(.REST_SERVICE_ERROR(error)))
				Log.error(error.localizedDescription, log: .ticketValidationDecorator)
			}
		}
	}
	
	// MARK: - Private
	
	private let restServiceProvider: RestServiceProviding
}
