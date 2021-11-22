//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData
	) {
		self.initializationData = initializationData
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
		case VS_ID_CLIENT_ERR
		case VS_ID_NO_NETWORK
		case VS_ID_SERVER_ERR
		case VS_ID_NO_ENC_KEY
		case VS_ID_NO_SIGN_KEY
		case VS_ID_CERT_PIN_NO_JWK_FOR_KID
		case VS_ID_CERT_PIN_MISMATCH
		case VS_ID_PARSE_ERR
		case VS_ID_EMPTY_X5C
	}
	
	func requestServiceIdentityDocument(
		validationServiceData: ValidationServiceData,
		validationServiceJwkSet: [JSONWebKey]
	) -> Result<ServiceIdentityRequestResult, ServiceIdentityRequestError> {
			
			
		return .failure(.VS_ID_CERT_PIN_MISMATCH)
	}
}
