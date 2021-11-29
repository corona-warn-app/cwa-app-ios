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
		completion: @escaping (Result<TicketValidationAccessTokenResult, AccessTokenRequestError>) -> Void
	) {
		guard let nonceBase64 = jwtWithHeadersModel.headers["x-nonce"] as? String else {
			Log.error("Missing header field x-nonce", log: .ticketValidation)
			completion(.failure(.UNKNOWN))
			return
		}

		let accessToken = jwtWithHeadersModel.jwt

		switch jwtVerification.verify(jwtString: accessToken, against: accessTokenSignJwkSet) {
		case .success:
			guard let jwtObject = try? JWT<TicketValidationAccessToken>(jwtString: accessToken) else {
				completion(.failure(.ATR_PARSE_ERR))
				return
			}

			let accessTokenPayload = jwtObject.claims

			guard accessTokenPayload.t == 1 || accessTokenPayload.t == 2 else {
				completion(.failure(.ATR_TYPE_INVALID))
				return
			}

			guard !accessTokenPayload.aud.trimmingCharacters(in: .whitespaces).isEmpty else {
				completion(.failure(.ATR_AUD_INVALID))
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

	private func mappedError(_ error: JWTVerificationError) -> AccessTokenRequestError {
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
