//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity
import SwiftJWT

struct TicketValidationAccessTokenResult {
	let accessToken: String
	let accessTokenPayload: TicketValidationAccessToken
	let nonceBase64: String
}

protocol TicketValidationAccessTokenProcessing {
	static func process(
		accessToken: String,
		accessTokenSignJwkSet: [JSONWebKey],
		nonceBase64: String,
		completion: @escaping (Result<TicketValidationAccessTokenResult, AccessTokenRequestError>) -> Void
	)
}

struct TicketValidationAccessTokenProcessor: TicketValidationAccessTokenProcessing {
	
	static func process(
		accessToken: String,
		accessTokenSignJwkSet: [JSONWebKey],
		nonceBase64: String,
		completion: @escaping (Result<TicketValidationAccessTokenResult, AccessTokenRequestError>) -> Void
	) {
		// Verifiy
		switch JWTVerification().verify(jwtString: accessToken, against: accessTokenSignJwkSet) {
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
			switch error {
			case .JWT_VER_ALG_NOT_SUPPORTED:
				completion(.failure(.ATR_JWT_VER_ALG_NOT_SUPPORTED))
			case .JWT_VER_EMPTY_JWKS:
				completion(.failure(.ATR_JWT_VER_EMPTY_JWKS))
			case .JWT_VER_NO_JWK_FOR_KID:
				completion(.failure(.ATR_JWT_VER_NO_JWK_FOR_KID))
			case .JWT_VER_NO_KID:
				completion(.failure(.ATR_JWT_VER_NO_KID))
			case .JWT_VER_SIG_INVALID:
				completion(.failure(.ATR_JWT_VER_SIG_INVALID))
			}

		}

		// Parsing

	}


}
