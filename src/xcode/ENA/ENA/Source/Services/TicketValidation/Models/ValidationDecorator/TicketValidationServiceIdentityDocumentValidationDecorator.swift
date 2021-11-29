//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

public struct TicketValidationServiceIdentityDocumentValidationDecorator: Codable {
	let accessTokenService: TicketValidationServiceData
	let accessTokenServiceJwkSet: [JSONWebKey?]
	let accessTokenSignJwkSet: [JSONWebKey?]
	let validationService: TicketValidationServiceData
	let validationServiceJwkSet: [JSONWebKey?]
}
