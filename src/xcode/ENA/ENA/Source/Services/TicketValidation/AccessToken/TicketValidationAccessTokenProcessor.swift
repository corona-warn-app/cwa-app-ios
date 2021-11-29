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
		jwtWithHeadersModel: JWTWithHeadersModel,
		accessTokenSignJwkSet: [JSONWebKey],
		completion: @escaping (Result<TicketValidationAccessTokenResult, TicketValidationAccessTokenProcessingError>) -> Void
	) {
		/// 2. Find `accessToken`: the `accessToken` shall be set to the body of the HTTP response.

		let accessToken = jwtWithHeadersModel.jwt

		/// 3. Verify signature: the signature of the `accessToken` shall be verified

		switch jwtVerification.verify(jwtString: accessToken, against: accessTokenSignJwkSet) {
		case .success:
			/// 4. Determine `accessTokenPayload`: the `accessTokenPayload` shall be set to the payload of the `accessToken`

			guard let jwtObject = try? JWT<TicketValidationAccessToken>(jwtString: accessToken) else {
				completion(.failure(.ATR_PARSE_ERR))
				return
			}

			let accessTokenPayload = jwtObject.claims

			/// 5. Validate `accessTokenPayload`

			guard accessTokenPayload.t == 1 || accessTokenPayload.t == 2 else {
				completion(.failure(.ATR_TYPE_INVALID))
				return
			}

			guard !accessTokenPayload.aud.trimmingCharacters(in: .whitespaces).isEmpty else {
				completion(.failure(.ATR_AUD_INVALID))
				return
			}

			/// 6. Determine `nonceBase64`: the `nonceBase64` shall be set to the value of the x-nonce header field in the HTTP response.

			guard let nonceBase64 = jwtWithHeadersModel.headers["x-nonce"] as? String else {
				Log.error("Missing header field x-nonce", log: .ticketValidation)
				completion(.failure(.UNKNOWN))
				return
			}

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
