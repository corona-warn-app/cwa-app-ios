//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

protocol TicketValidationServiceIdentityDocumentProcessing {
	func process(
		serviceIdentityDocument: TicketValidationServiceIdentityDocument,
		completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
	)
}

struct TicketValidationServiceIdentityDocumentProcessor: TicketValidationServiceIdentityDocumentProcessing {
	
	func process(
		serviceIdentityDocument: TicketValidationServiceIdentityDocument,
		completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
	) {
		Log.info("Process TicketValidationServiceIdentityDocument", log: .ticketValidation)

		// 2. Verify JWKs
		for verificationMethod in serviceIdentityDocument.verificationMethod {
			if let publicKeyJwk = verificationMethod.publicKeyJwk, publicKeyJwk.x5c.isEmpty {
				Log.error("Verify JWKs failed", log: .ticketValidation)
				completion(.failure(.VS_ID_EMPTY_X5C))
				return
			}
		}
		
		// 3. Find verificationMethodsForRSAOAEPWithSHA256AESCBC
		let cbcRegEx = "ValidationServiceEncScheme-RSAOAEPWithSHA256AESCBC$"
		let verificationMethodsForRSAOAEPWithSHA256AESCBC = serviceIdentityDocument.verificationMethod.first { verificationMethod in
			let regExExists = verificationMethod.id.check(regex: cbcRegEx)
			return regExExists && verificationMethod.verificationMethods != nil
		}?.verificationMethods ?? []
		
		// 4. Find validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC
		let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC = serviceIdentityDocument.verificationMethod.filter { verificationMethod in
			verificationMethodsForRSAOAEPWithSHA256AESCBC.contains(verificationMethod.id)
		}.compactMap { verificationMethod in
			verificationMethod.publicKeyJwk
		}
		Log.debug("Found validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: \(private: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC)", log: .ticketValidation)
		
		// 5. Find verificationMethodsForRSAOAEPWithSHA256AESGCM
		let gcmRegEx = "ValidationServiceEncScheme-RSAOAEPWithSHA256AESGCM$"
		let verificationMethodsForRSAOAEPWithSHA256AESGCM = serviceIdentityDocument.verificationMethod.first { verificationMethod in
			let regExExists = verificationMethod.id.check(regex: gcmRegEx)
			return regExExists && verificationMethod.verificationMethods != nil
		}?.verificationMethods ?? []
		
		// 6. Find validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM
		let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM = serviceIdentityDocument.verificationMethod.filter { verificationMethod in
			verificationMethodsForRSAOAEPWithSHA256AESGCM.contains(verificationMethod.id)
		}.compactMap { verificationMethod in
			verificationMethod.publicKeyJwk
		}
		Log.debug("Found validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: \(private: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM)")
		
		// 7. Check encryption keys
		if validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC.isEmpty && validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM.isEmpty {
			Log.error("No encryption keys found. Error: VS_ID_NO_ENC_KEY", log: .ticketValidation)
			completion(.failure(.VS_ID_NO_ENC_KEY))
			return
		}
		
		// 8. Find validationServiceSignKeyJwkSet
		let regex = "ValidationServiceSignKey-\\d+$"
		let validationServiceSignKeyJwkSet = serviceIdentityDocument.verificationMethod.filter { verificationMethod in
			verificationMethod.id.check(regex: regex)
		}.compactMap { verificationMethod in
			verificationMethod.publicKeyJwk
		}
		
		if validationServiceSignKeyJwkSet.isEmpty {
			Log.error("No signing keys found. Error: VS_ID_NO_SIGN_KEY", log: .ticketValidation)
			completion(.failure(.VS_ID_NO_SIGN_KEY))
			return
		}
		Log.debug("Found validationServiceSignKeyJwkSet: \(private: validationServiceSignKeyJwkSet)")

		let result = ServiceIdentityRequestResult(
			validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC,
			validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM,
			validationServiceSignKeyJwkSet: validationServiceSignKeyJwkSet
		)
		
		Log.info("Finished processing TicketValidationServiceIdentityDocument", log: .ticketValidation)

		completion(.success(result))
	}
}
