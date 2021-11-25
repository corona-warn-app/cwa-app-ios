//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

public struct DecoratorIdentityDocument: Codable {
	let accessTokenService: DecoratorServiceModel
	let accessTokenServiceJwkSet: [JSONWebKey?]
	let accessTokenSignJwkSet: [JSONWebKey?]
	let validationService: DecoratorServiceModel
	let validationServiceJwkSet: [JSONWebKey?]
}
