//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

public struct DecoratorIdentityDocument: Codable {
	let accessTokenService: DecoratorService
	let accessTokenServiceJwkSet: [JSONWebKey?]
	let accessTokenSignJwkSet: [JSONWebKey?]
	let validationService: DecoratorService
	let validationServiceJwkSet: [JSONWebKey?]
}
