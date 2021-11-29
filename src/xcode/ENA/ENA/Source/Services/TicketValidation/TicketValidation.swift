//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

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
		completion: @escaping (Result<TicketValidationResultToken, TicketValidationError>) -> Void
	) {

	}

	func cancel() {

	}
	
	// MARK: - Private

    private let restServiceProvider: RestServiceProvider

	private func requestAccessToken(
		accessTokenService: TicketValidationServiceData,
		accessTokenServiceJwkSet: [JSONWebKey],
		accessTokenSignJwkSet: [JSONWebKey],
		jwt: String,
		validationService: TicketValidationServiceData,
		publicKeyBase64: String,
		completion: @escaping (Result<TicketValidationAccessTokenResult, AccessTokenRequestError>) -> Void
	) {
		guard let url = URL(string: accessTokenService.serviceEndpoint) else {
			Log.error("Invalid access token service endpoint", log: .ticketValidation)
			completion(.failure(.UNKNOWN))
			return
		}

		let resource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: url,
			jwt: jwt
		)

		restServiceProvider.update(
			DynamicEvaluateTrust(
				jwkSet: accessTokenServiceJwkSet,
				trustEvaluation: TrustEvaluation()
			)
		)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let jwtWithHeadersModel):
				TicketValidationAccessTokenProcessor(jwtVerification: JWTVerification())
					.process(
						jwtWithHeadersModel: jwtWithHeadersModel,
						accessTokenSignJwkSet: accessTokenSignJwkSet,
						completion: completion
					)
			case .failure(let error):
				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}

}
