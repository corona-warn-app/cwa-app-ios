//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class TicketValidation: TicketValidating {
	
	// MARK: - Protocol TicketValidating

	init(
		with initializationData: TicketValidationInitializationData,
		restServiceProvider: RestServiceProviding,
		serviceIdentityProcessor: TicketValidationServiceIdentityDocumentProcessing
	) {
		self.initializationData = initializationData
		self.restServiceProvider = restServiceProvider
		self.serviceIdentityProcessor = serviceIdentityProcessor
	}

	let initializationData: TicketValidationInitializationData

	func initialize(
		completion: @escaping (Result<Void, TicketValidationError>) -> Void
	) {
		validateIdentityDocumentOfValidationDecorator(
			urlString: initializationData.serviceIdentity
		) { [weak self] result in
			switch result {
			case .success(let validationDecoratorDocument):
				self?.validationDecoratorDocument = validationDecoratorDocument
				completion(.success(()))
			case .failure(let error):
				completion(.failure(.validationDecoratorDocument(error)))
			}
		}
	}

	func grantFirstConsent(
		completion: @escaping (Result<TicketValidationConditions, TicketValidationError>) -> Void
	) {
		Log.info("Grant first consent.", log: .ticketValidation)

		guard let validationDecoratorDocument = validationDecoratorDocument else {
			Log.error("grantFirstConsent called too early")
			completion(.failure(.other))
			return
		}

		requestServiceIdentityDocument(
			validationServiceData: validationDecoratorDocument.validationService,
			validationServiceJwkSet: validationDecoratorDocument.validationServiceJwkSet
		) { [weak self] result in
			guard let self = self else {
				return
			}

			switch result {
			case .success(let validationServiceDocument):
				self.validationServiceDocument = validationServiceDocument

				let keyPair: ECKeyPair

				switch ECKeyPairGeneration().generateECPair() {
				case .success(let generatedKeyPair):
					keyPair = generatedKeyPair
					self.keyPair = keyPair
				case .failure(let error):
					completion(.failure(.keyPairGeneration(error)))
					return
				}

				self.requestAccessToken(
					accessTokenService: validationDecoratorDocument.accessTokenService,
					accessTokenServiceJwkSet: validationDecoratorDocument.accessTokenServiceJwkSet,
					accessTokenSignJwkSet: validationDecoratorDocument.accessTokenSignJwkSet,
					jwt: self.initializationData.token,
					validationService: validationDecoratorDocument.validationService,
					publicKeyBase64: keyPair.publicKeyBase64
				) { result in
					switch result {
					case .success(let accessTokenResult):
						self.accessTokenResult = accessTokenResult
						completion(.success(accessTokenResult.accessTokenPayload.vc))
					case .failure(let error):
						completion(.failure(.accessToken(error)))
					}
				}
			case .failure(let error):
				completion(.failure(.validationServiceDocument(error)))
			}
		}
	}

	func selectCertificate(
		_ healthCertificate: HealthCertificate
	) {
		selectedHealthCertificate = healthCertificate
	}

	func validate(
		completion: @escaping (Result<TicketValidationResultToken, TicketValidationError>) -> Void
	) {

		/// 1.  Determine `encryptionParameters`

		let encryptionScheme: EncryptionScheme
		let jwk: JSONWebKey

		if let firstGCMKey = validationServiceDocument?.validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM.first {
			encryptionScheme = .RSAOAEPWithSHA256AESGCM
			jwk = firstGCMKey
		} else if let firstCBCKey = validationServiceDocument?.validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC.first {
			encryptionScheme = .RSAOAEPWithSHA256AESCBC
			jwk = firstCBCKey
		} else {
			completion(.failure(.validationServiceDocument(.VS_ID_NO_ENC_KEY)))
			return
		}

		/// 2. Determine `publicKeyForEncryption`

		guard let publicKey = jwk.publicRSASecKey else {
			completion(.failure(.other))
			return
		}

		/// 3. Encrypt and sign DCC

		guard let selectedHealthCertificate = selectedHealthCertificate, let accessTokenResult = accessTokenResult, let keyPair = keyPair, let validationDecoratorDocument = validationDecoratorDocument, let validationServiceDocument = validationServiceDocument else {
			Log.error("validate called too early")
			completion(.failure(.other))
			return
		}

		let result = DCCEncryption().encryptAndSignDCC(
			dccBarcodeData: selectedHealthCertificate.base45,
			nonceBase64: accessTokenResult.nonceBase64,
			encryptionScheme: encryptionScheme,
			publicKeyForEncryption: publicKey,
			privateKeyForSigning: keyPair.privateKey
		)

		switch result {
		case .success(let encryptionResult):
			self.encryptionResult = encryptionResult

			requestResultToken(
				serviceEndpoint: accessTokenResult.accessTokenPayload.aud,
				validationServiceJwkSet: validationDecoratorDocument.validationServiceJwkSet,
				validationServiceSignJwkSet: validationServiceDocument.validationServiceSignKeyJwkSet,
				jwt: accessTokenResult.accessToken,
				encryptionKeyKid: jwk.kid,
				encryptedDCCBase64: encryptionResult.encryptedDCCBase64,
				encryptionKeyBase64: encryptionResult.encryptionKeyBase64,
				signatureBase64: encryptionResult.signatureBase64,
				signatureAlgorithm: encryptionResult.signatureAlgorithm,
				encryptionScheme: encryptionScheme
			) { [weak self] resultTokenRequestResult in
				switch resultTokenRequestResult {
				case .success(let resultTokenResult):
					self?.resultTokenResult = resultTokenResult
					completion(.success(resultTokenResult.resultTokenPayload))
				case .failure(let error):
					completion(.failure(.resultToken(error)))
				}
			}
		case .failure(let error):
			completion(.failure(.encryption(error)))
		}
	}

	func cancel() {

	}

	// MARK: - Private

	private let restServiceProvider: RestServiceProviding
	private let serviceIdentityProcessor: TicketValidationServiceIdentityDocumentProcessing

	private var validationDecoratorDocument: TicketValidationServiceIdentityDocumentValidationDecorator?
	private var validationServiceDocument: ServiceIdentityRequestResult?
	private var accessTokenResult: TicketValidationAccessTokenResult?
	private var resultTokenResult: TicketValidationResultTokenResult?
	private var keyPair: ECKeyPair?
	private var encryptionResult: EncryptAndSignResult?

	private var selectedHealthCertificate: HealthCertificate?
	
	private func validateIdentityDocumentOfValidationDecorator(
		urlString: String,
		completion:
		@escaping (Result<TicketValidationServiceIdentityDocumentValidationDecorator, ServiceIdentityValidationDecoratorError>) -> Void
	) {
		Log.info("Validate identity document of validation decorator.", log: .ticketValidation)

		guard let url = URL(string: urlString) else {
			Log.error("URL cant be constructed from input string", log: .ticketValidationDecorator)
			return
		}
		
		Log.debug("Request document of validation decorator at URL: \(url)", log: .ticketValidation)
		
		let resource = ServiceIdentityDocumentValidationDecoratorResource(url: url)
		restServiceProvider.load(resource) { result in
			switch result {
			case .success(let model):
				TicketValidationDecoratorIdentityDocumentProcessor().validateIdentityDocument(serviceIdentityDocument: model) { result in
					completion(result)
				}
			case .failure(let error):
				Log.error("Failed to request document of validation decorator with error: \(error)", log: .ticketValidation)

				completion(.failure(.REST_SERVICE_ERROR(error)))
				Log.error(error.localizedDescription, log: .ticketValidationDecorator)
			}
		}
	}

	private func requestServiceIdentityDocument(
		validationServiceData: TicketValidationServiceData,
		validationServiceJwkSet: [JSONWebKey],
		completion: @escaping (Result<ServiceIdentityRequestResult, ServiceIdentityRequestError>) -> Void
	) {
		Log.info("Request document of service identity", log: .ticketValidation)

		guard let url = URL(string: validationServiceData.serviceEndpoint) else {
			completion(.failure(.UNKOWN))
			return
		}

		Log.debug("Request document of service identity at URL: \(url)", log: .ticketValidation)

		let resource = ServiceIdentityDocumentResource(endpointUrl: url)
		restServiceProvider.update(
			DynamicEvaluateTrust(
				jwkSet: validationServiceJwkSet,
				trustEvaluation: TrustEvaluation()
			)
		)

		restServiceProvider.load(resource) { [weak self] result in
			switch result {
			case .success(let serviceIdentityDocument):
				self?.serviceIdentityProcessor.process(
					serviceIdentityDocument: serviceIdentityDocument,
					completion: completion
				)
			case .failure(let error):
				Log.error("Failed to request document of service identity with error: \(error)", log: .ticketValidation)
				
				completion(.failure(.REST_SERVICE_ERROR(error)))
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
		Log.info("Request access token", log: .ticketValidation)

        guard let url = URL(string: accessTokenService.serviceEndpoint) else {
            Log.error("Invalid access token service endpoint", log: .ticketValidation)
            completion(.failure(.UNKNOWN))
            return
        }

		Log.debug("Request access token at URL: \(url)", log: .ticketValidation)

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
		encryptionScheme: EncryptionScheme,
		completion: @escaping (Result<TicketValidationResultTokenResult, TicketValidationResultTokenProcessingError>) -> Void
	) {
		Log.info("Request result token", log: .ticketValidation)

		guard let url = URL(string: serviceEndpoint) else {
			Log.error("Invalid result token service endpoint", log: .ticketValidation)
			completion(.failure(.UNKNOWN))
			return
		}

		Log.debug("Request result token at URL: \(url)", log: .ticketValidation)

		let resource = TicketValidationResultTokenResource(
			resultTokenServiceURL: url,
			jwt: jwt,
			sendModel: TicketValidationResultTokenSendModel(
				kid: encryptionKeyKid,
				dcc: encryptedDCCBase64,
				sig: signatureBase64,
				encKey: encryptionKeyBase64,
				encScheme: encryptionScheme.rawValue,
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
