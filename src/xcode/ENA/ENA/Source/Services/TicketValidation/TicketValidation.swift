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

	private func validateIdentityDocumentOfValidationDecorator(
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

	// swiftlint:disable function_parameter_count
	private func requestResultToken(
		serviceEndpoint: String,
		validationServiceJwkSet: [JSONWebKey],
		validationServiceSignJwkSet: [JSONWebKey],
		jwt: String,
		encryptionKeyKid: String,
		encryptedDCCBase64: String,
		encryptionKeyBase64: String,
		signatureBase64: String,
		signatureAlgorithm: String,
		encryptionScheme: String,
		completion: @escaping (Result<TicketValidationResultTokenResult, TicketValidationResultTokenProcessingError>) -> Void
	) {
		guard let url = URL(string: serviceEndpoint) else {
			Log.error("Invalid result token service endpoint", log: .ticketValidation)
			completion(.failure(.UNKNOWN))
			return
		}

		let resource = TicketValidationResultTokenResource(
			resultTokenServiceURL: url,
			jwt: jwt,
			sendModel: TicketValidationResultTokenSendModel(
				kid: encryptionKeyKid,
				dcc: encryptedDCCBase64,
				sig: signatureBase64,
				encKey: encryptionKeyBase64,
				encScheme: encryptionScheme,
				sigAlg: signatureAlgorithm
			)
		)

		restServiceProvider.update(
			DynamicEvaluateTrust(
				jwkSet: validationServiceJwkSet,
				trustEvaluation: TrustEvaluation()
			)
		)

		Log.info("Ticket Validation: Requesting result token", log: .ticketValidation)

		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let resultToken):
				TicketValidationResultTokenProcessor(jwtVerification: JWTVerification())
					.process(
						resultToken: resultToken,
						validationServiceSignJwkSet: validationServiceSignJwkSet,
						completion: completion
					)
			case .failure(let error):
				Log.error("Ticket Validation: Requesting result token failed", log: .ticketValidation, error: error)

				completion(.failure(.REST_SERVICE_ERROR(error)))
			}
		}
	}

}
