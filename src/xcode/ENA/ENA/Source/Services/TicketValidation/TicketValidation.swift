//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

enum ServiceIdentityRequestError: Error {
    case VS_ID_NO_ENC_KEY
    case VS_ID_NO_SIGN_KEY
    case VS_ID_EMPTY_X5C
    case REST_SERVICE_ERROR(ServiceError<TicketValidationAccessTokenError>)
    case UNKOWN
}

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData,
        restServiceProvider: RestServiceProvider
	) {
		self.initializationData = initializationData
        self.restServiceProvider = restServiceProvider
	}

	let initializationData: TicketValidationInitializationData

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

	struct TicketValidationAccessTokenResult {
		let accessToken: String
		let accessTokenPayload: TicketValidationAccessToken
		let nonceBase64: String
	}

    func requestAccessToken(
        accessTokenService: TicketValidationServiceData,
        accessTokenServiceJwkSet: [JSONWebKey],
        accessTokenSignJwkSet: [JSONWebKey],
        jwt: String,
        validationService: TicketValidationServiceData,
        publicKeyBase64: String,
        completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
    ) {
        guard let url = URL(string: accessTokenService.serviceEndpoint) else {
            completion(.failure(.UNKOWN))
            return
        }

        let resource = TicketValidationAccessTokenResource(
            accessTokenServiceURL: accessTokenService.url,
            jwt: jwt
        )

        restServiceProvider.update(
            DynamicEvaluateTrust(
                jwkSet: accessTokenServiceJwkSet,
                trustEvaluation: TrustEvaluation()
            )
        )

        restServiceProvider.load(resource) { [weak self] result in
            switch result {
            case .success(let accessToken):
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
	
	// MARK: - Private

    private let restServiceProvider: RestServiceProvider

}
