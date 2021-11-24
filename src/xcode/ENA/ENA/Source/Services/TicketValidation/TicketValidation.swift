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
	private let restServiceProvider: RestServiceProviding
	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {

	}

	func grantFirstConsent(
		completion: @escaping (Result<ValidationConditions, TicketValidationError>) -> Void
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

	// swiftlint:disable:next cyclomatic_complexity
	func requestIdentityDocumentOfTheValidationDecorator(
		urlString: String,
		completion:
		@escaping (Result<DecoratorIdentityDocument, DecoratorServiceIdentityDocumentError>) -> Void
	) {
		guard let url = URL(string: urlString) else {
			Log.error("URL cant be constructed from input string", log: .ticketValidationDecorator)
			return
		}
		let resource = DecoratorIdentityDocumentResource(url: url)
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				// 2 - Verify JWKs
				for method in model.verificationMethod {
					if let publicKeyJwk = method.publicKeyJwk, publicKeyJwk.x5c.isEmpty {
						Log.error("x5c is empty", log: .ticketValidationDecorator)
						completion(.failure(.VD_ID_EMPTY_X5C))
					}
				}
				// 3 - Find accessTokenService
				guard let accessTokenService = model.service?.first(where: {
					$0.type == "AccessTokenService"
				}) else {
					Log.error("no match for accessTokenService", log: .ticketValidationDecorator)
					completion(.failure(.VD_ID_NO_ATS))
					return
				}
				Log.debug("accessTokenService: \(accessTokenService)", log: .ticketValidationDecorator)

				// 4 - Find accessTokenSignJwkSet
				let matchedAccessSignMethods = model.verificationMethod.filter({
					$0.id.range(of: #"AccessTokenSignKey-\d+$"#, options: .regularExpression) != nil
				})
				if matchedAccessSignMethods.isEmpty {
					Log.error("accessTokenSignJwkSet is empty", log: .ticketValidationDecorator)
					completion(.failure(.VD_ID_NO_ATS_SIGN_KEY))
					return
				}
				let accessTokenSignJwkSet = matchedAccessSignMethods.map({
					$0.publicKeyJwk
				})
				Log.debug("\(accessTokenSignJwkSet)", log: .ticketValidationDecorator)

				// 5 - Find accessTokenServiceJwkSet
				let matchedAccessServiceMethods = model.verificationMethod.filter({
					$0.id.range(of: #"AccessTokenServiceKey-\d+$"#, options: .regularExpression) != nil
				})
				if matchedAccessServiceMethods.isEmpty {
					Log.error("matchedAccessServiceMethods is empty", log: .ticketValidationDecorator)
					completion(.failure(.VD_ID_NO_ATS_SVC_KEY))
					return
				}
				let accessTokenServiceJwkSet = matchedAccessServiceMethods.map({
					$0.publicKeyJwk
				})
				Log.debug("\(accessTokenServiceJwkSet)", log: .ticketValidationDecorator)

				// 6 - Find validationService
				guard let validationService = model.service?.first(where: {
					$0.type == "ValidationService"
				}) else {
					Log.error("no match for validation service", log: .ticketValidationDecorator)
					completion(.failure(.VD_ID_NO_VS))
					return
				}
				Log.debug("\(validationService)", log: .ticketValidationDecorator)
				
				// 7 - Find validationServiceJwkSet
				let matchedValidationServiceMethods = model.verificationMethod.filter({
					$0.id.range(of: #"ValidationServiceKey-\d+$"#, options: .regularExpression) != nil
				})
				if matchedValidationServiceMethods.isEmpty {
					Log.error("matchedValidationServiceMethods is empty", log: .ticketValidationDecorator)
					completion(.failure(.VD_ID_NO_VS_SVC_KEY))
					return
				}
				let validationServiceJwkSet = matchedValidationServiceMethods.map({
					$0.publicKeyJwk
				})
				Log.debug("\(validationServiceJwkSet)", log: .ticketValidationDecorator)
				
				completion(
					.success(
						DecoratorIdentityDocument(
							accessTokenService: accessTokenService,
							accessTokenServiceJwkSet: accessTokenServiceJwkSet,
							accessTokenSignJwkSet: accessTokenSignJwkSet,
							validationService: validationService,
							validationServiceJwkSet: validationServiceJwkSet)
					)
				)
			case .failure(let error):
				guard let customError = resource.customError(for: error) else {
					Log.error("couldn't convert to custom error", log: .ticketValidationDecorator)
					return
				}
				completion(.failure(customError))
				Log.error(error.localizedDescription, log: .ticketValidationDecorator)
			}
		}
	}
}
