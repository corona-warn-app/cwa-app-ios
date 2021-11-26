//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

public struct TicketValidationServiceIdentityDocumentValidationDecorator: Codable {
	let accessTokenService: TicketValidationValidationServiceData
	let accessTokenServiceJwkSet: [JSONWebKey?]
	let accessTokenSignJwkSet: [JSONWebKey?]
	let validationService: TicketValidationValidationServiceData
	let validationServiceJwkSet: [JSONWebKey?]
}
