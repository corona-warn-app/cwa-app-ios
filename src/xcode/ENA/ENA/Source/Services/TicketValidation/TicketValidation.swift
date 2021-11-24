//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

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
	
	func requestServiceIdentityDocument(
		validationServiceData: ValidationServiceData,
		validationServiceJwkSet: [JSONWebKey],
		completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
	) {
		
		guard let url = URL(string: validationServiceData.serviceEndpoint) else {
			completion(.failure(.UNKOWN))
			return
		}
		
		let resource = ServiceIdentityDocumentResource(endpointUrl: url)
		
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let serviceIdentityDocument):
                
				// 2. Verifiy JWKs
				for verificationMethod in serviceIdentityDocument.verificationMethod {
                    if let publicKeyJwk = verificationMethod.publicKeyJwk, publicKeyJwk.x5c.isEmpty {
						Log.error("Verify JWKs failed", log: .ticketValidation)
						completion(.failure(.VS_ID_EMPTY_X5C))
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
					completion(.failure(.VS_ID_NO_SIGN_KEY))
					return
				}
				Log.debug("Found validationServiceSignKeyJwkSet: \(private: validationServiceSignKeyJwkSet)")

				let result = ServiceIdentityRequestResult(
					validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC,
					validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM,
					validationServiceSignKeyJwkSet: validationServiceSignKeyJwkSet
				)
				completion(.success(result))
				
			case .failure(let error):
				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}
	
	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	
}
