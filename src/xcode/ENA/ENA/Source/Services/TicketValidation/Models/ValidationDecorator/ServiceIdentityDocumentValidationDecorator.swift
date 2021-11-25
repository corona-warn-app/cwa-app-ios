//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

public struct ServiceIdentityDocumentValidationDecorator: Codable {
	let accessTokenService: ValidationDecoratorServiceModel
	let accessTokenServiceJwkSet: [JSONWebKey?]
	let accessTokenSignJwkSet: [JSONWebKey?]
	let validationService: ValidationDecoratorServiceModel
	let validationServiceJwkSet: [JSONWebKey?]
}
