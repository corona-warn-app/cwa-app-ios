//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import SwiftJWT

struct TicketValidationResultTokenProcessor {

	// MARK: - Init

	init(jwtVerification: JWTVerifying) {
		self.jwtVerification = jwtVerification
	}

	// MARK: - Internal

	func process(
		resultToken: String,
		validationServiceSignJwkSet: [JSONWebKey],
		completion: @escaping (Result<TicketValidationResultTokenResult, TicketValidationResultTokenProcessingError>) -> Void
	) {
		// 3. Verify signature

		Log.info("Ticket Validation: Verifying result token signature", log: .ticketValidation)

		switch jwtVerification.verify(jwtString: resultToken, against: validationServiceSignJwkSet) {
		case .success:
			Log.info("Ticket Validation: Verifying result token signature succeeded", log: .ticketValidation)

			// 4. Determine `resultTokenPayload`

			guard let jwtObject = try? JWT<TicketValidationResultToken>(jwtString: resultToken) else {
				Log.error("Ticket Validation: Parsing result token failed", log: .ticketValidation)

				completion(.failure(.RTR_PARSE_ERR))
				return
			}

			let resultTokenPayload = jwtObject.claims

			Log.info("Ticket Validation: result token processing succeeded", log: .ticketValidation)

			completion(
				.success(
					TicketValidationResultTokenResult(
						resultToken: resultToken,
						resultTokenPayload: resultTokenPayload
					)
				)
			)
		case .failure(let error):
			Log.error("Ticket Validation: Verifying result token signature failed", log: .ticketValidation, error: error)

			completion(.failure(mappedError(error)))
		}

	}

	// MARK: - Private

	private let jwtVerification: JWTVerifying

	private func mappedError(_ error: JWTVerificationError) -> TicketValidationResultTokenProcessingError {
		switch error {
		case .JWT_VER_ALG_NOT_SUPPORTED:
			return .RTR_JWT_VER_ALG_NOT_SUPPORTED
		case .JWT_VER_EMPTY_JWKS:
			return .RTR_JWT_VER_EMPTY_JWKS
		case .JWT_VER_NO_JWK_FOR_KID:
			return .RTR_JWT_VER_NO_JWK_FOR_KID
		case .JWT_VER_NO_KID:
			return .RTR_JWT_VER_NO_KID
		case .JWT_VER_SIG_INVALID:
			return .RTR_JWT_VER_SIG_INVALID
		}
	}

}
