//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import SwiftJWT

struct TicketValidationAccessTokenProcessor {

	// MARK: - Init

	init(jwtVerification: JWTVerifying) {
		self.jwtVerification = jwtVerification
	}

	// MARK: - Internal
	
	func process(
		ticketValidationModel: TicketValidationAccessTokenReceiveModel,
		accessTokenSignJwkSet: [JSONWebKey],
		completion: @escaping (Result<TicketValidationAccessTokenResult, TicketValidationAccessTokenProcessingError>) -> Void
	) {
		/// 2. Find `accessToken`

		let accessToken = ticketValidationModel.token

		/// 3. Verify signature

		Log.info("Ticket Validation: Verifying access token signature", log: .ticketValidation)

		switch jwtVerification.verify(jwtString: accessToken, against: accessTokenSignJwkSet) {
		case .success:
			Log.info("Ticket Validation: Verifying access token signature succeeded", log: .ticketValidation)

			/// 4. Determine `accessTokenPayload`

			guard let jwtObject = try? JWT<TicketValidationAccessToken>(jwtString: accessToken) else {
				Log.error("Ticket Validation: Parsing access token failed", log: .ticketValidation)

				completion(.failure(.ATR_PARSE_ERR))
				return
			}

			let accessTokenPayload = jwtObject.claims

			/// 5. Validate `accessTokenPayload`

			guard accessTokenPayload.t == 1 || accessTokenPayload.t == 2 else {
				Log.error("Ticket Validation: Access token payload t is \(private: accessTokenPayload.t)", log: .ticketValidation)

				completion(.failure(.ATR_TYPE_INVALID))
				return
			}

			guard !accessTokenPayload.aud.trimmingCharacters(in: .whitespaces).isEmpty else {
				Log.error("Ticket Validation: Access token payload aud is empty", log: .ticketValidation)

				completion(.failure(.ATR_AUD_INVALID))
				return
			}

			/// 6. Determine `nonceBase64`

			guard let nonceBase64 = ticketValidationModel.metaData.headers["x-nonce"] as? String else {
				Log.error("Ticket Validation: Missing header field x-nonce", log: .ticketValidation)

				completion(.failure(.UNKNOWN))
				return
			}

			Log.info("Ticket Validation: access token processing succeeded", log: .ticketValidation)

			completion(
				.success(
					TicketValidationAccessTokenResult(
						accessToken: accessToken,
						accessTokenPayload: accessTokenPayload,
						nonceBase64: nonceBase64
					)
				)
			)
		case .failure(let error):
			Log.error("Ticket Validation: Verifying access token signature failed", log: .ticketValidation, error: error)

			completion(.failure(mappedError(error)))
		}

	}

	// MARK: - Private

	private let jwtVerification: JWTVerifying

	private func mappedError(_ error: JWTVerificationError) -> TicketValidationAccessTokenProcessingError {
		switch error {
		case .JWT_VER_ALG_NOT_SUPPORTED:
			return .ATR_JWT_VER_ALG_NOT_SUPPORTED
		case .JWT_VER_EMPTY_JWKS:
			return .ATR_JWT_VER_EMPTY_JWKS
		case .JWT_VER_NO_JWK_FOR_KID:
			return .ATR_JWT_VER_NO_JWK_FOR_KID
		case .JWT_VER_NO_KID:
			return .ATR_JWT_VER_NO_KID
		case .JWT_VER_SIG_INVALID:
			return .ATR_JWT_VER_SIG_INVALID
		}
	}

}
