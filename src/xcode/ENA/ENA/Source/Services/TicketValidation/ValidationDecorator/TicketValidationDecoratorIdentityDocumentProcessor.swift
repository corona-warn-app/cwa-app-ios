//
// 🦠 Corona-Warn-App
//

import Foundation

final class TicketValidationDecoratorIdentityDocumentProcessor {
	
	func validateIdentityDocument(
		serviceIdentityDocument: TicketValidationServiceIdentityDocument,
		completion:
		@escaping (Result<TicketValidationServiceIdentityDocumentValidationDecorator, ServiceIdentityValidationDecoratorError>) -> Void
	) {
		Log.info("Started validation of identity document.", log: .ticketValidation)

		// 2 - Verify JWKs
		for method in serviceIdentityDocument.verificationMethod {
			if let publicKeyJwk = method.publicKeyJwk, publicKeyJwk.x5c.isEmpty {
				Log.error("x5c is empty", log: .ticketValidationDecorator)
				completion(.failure(.VD_ID_EMPTY_X5C))
				return
			}
		}
		// 3 - Find accessTokenService
		guard let accessTokenService = serviceIdentityDocument.service?.first(where: {
			$0.type == "AccessTokenService"
		}) else {
			Log.error("no match for accessTokenService", log: .ticketValidationDecorator)
			completion(.failure(.VD_ID_NO_ATS))
			return
		}
		Log.debug("accessTokenService: \(accessTokenService)", log: .ticketValidationDecorator)
		
		// 4 - Find accessTokenSignJwkSet
		let matchedAccessSignMethods = serviceIdentityDocument.verificationMethod.filter({
			$0.id.range(of: #"AccessTokenSignKey-\d+$"#, options: .regularExpression) != nil
		})
		if matchedAccessSignMethods.isEmpty {
			Log.error("accessTokenSignJwkSet is empty", log: .ticketValidationDecorator)
			completion(.failure(.VD_ID_NO_ATS_SIGN_KEY))
			return
		}
		let accessTokenSignJwkSet = matchedAccessSignMethods.compactMap {
			$0.publicKeyJwk
		}
		Log.debug("accessTokenSignJwkSet: \(private: accessTokenSignJwkSet)", log: .ticketValidationDecorator)
		
		// 5 - Find accessTokenServiceJwkSet
		let matchedAccessServiceMethods = serviceIdentityDocument.verificationMethod.filter({
			$0.id.range(of: #"AccessTokenServiceKey-\d+$"#, options: .regularExpression) != nil
		})
		if matchedAccessServiceMethods.isEmpty {
			Log.error("matchedAccessServiceMethods is empty", log: .ticketValidationDecorator)
			completion(.failure(.VD_ID_NO_ATS_SVC_KEY))
			return
		}
		let accessTokenServiceJwkSet = matchedAccessServiceMethods.compactMap {
			$0.publicKeyJwk
		}
		Log.debug("accessTokenServiceJwkSet: \(private: accessTokenServiceJwkSet)", log: .ticketValidationDecorator)
		
		// 6 - Find validationService
		guard let validationService = serviceIdentityDocument.service?.first(where: {
			$0.type == "ValidationService"
		}) else {
			Log.error("no match for validation service", log: .ticketValidationDecorator)
			completion(.failure(.VD_ID_NO_VS))
			return
		}
		Log.debug("\(validationService)", log: .ticketValidationDecorator)
		
		// 7 - Find validationServiceJwkSet
		let matchedValidationServiceMethods = serviceIdentityDocument.verificationMethod.filter({
			$0.id.range(of: #"ValidationServiceKey-\d+$"#, options: .regularExpression) != nil
		})
		if matchedValidationServiceMethods.isEmpty {
			Log.error("matchedValidationServiceMethods is empty", log: .ticketValidationDecorator)
			completion(.failure(.VD_ID_NO_VS_SVC_KEY))
			return
		}
		let validationServiceJwkSet = matchedValidationServiceMethods.compactMap {
			$0.publicKeyJwk
		}
		Log.debug("validationServiceJwkSet: \(private: validationServiceJwkSet)", log: .ticketValidationDecorator)
		Log.info("Finished validation of identity document.", log: .ticketValidation)

		completion(
			.success(
				TicketValidationServiceIdentityDocumentValidationDecorator(
					accessTokenService: accessTokenService,
					accessTokenServiceJwkSet: accessTokenServiceJwkSet,
					accessTokenSignJwkSet: accessTokenSignJwkSet,
					validationService: validationService,
					validationServiceJwkSet: validationServiceJwkSet)
			)
		)
	}
	
}
