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
