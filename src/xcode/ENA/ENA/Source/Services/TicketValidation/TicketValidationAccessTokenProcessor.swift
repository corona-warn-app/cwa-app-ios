//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

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


	}
}
