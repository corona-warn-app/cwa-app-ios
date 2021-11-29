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
		completion: @escaping (Result<TicketValidationResult, TicketValidationError>) -> Void
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
		completion: @escaping (Result<TicketValidationAccessTokenResult, TicketValidationAccessTokenProcessingError>) -> Void
	) {
		guard let url = URL(string: accessTokenService.serviceEndpoint) else {
			Log.error("Invalid access token service endpoint", log: .ticketValidation)
			completion(.failure(.UNKNOWN))
			return
		}

		let resource = TicketValidationAccessTokenResource(
			accessTokenServiceURL: url,
			jwt: jwt,
			sendModel: TicketValidationAccessTokenSendModel(
				service: validationService.id,
				pubKey: publicKeyBase64
			)
		)

		restServiceProvider.update(
			DynamicEvaluateTrust(
				jwkSet: accessTokenServiceJwkSet,
				trustEvaluation: TrustEvaluation()
			)
		)

		Log.info("Ticket Validation: Requesting access token", log: .ticketValidation)

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
				Log.error("Ticket Validation: Requesting access token failed", log: .ticketValidation, error: error)

				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}

}
