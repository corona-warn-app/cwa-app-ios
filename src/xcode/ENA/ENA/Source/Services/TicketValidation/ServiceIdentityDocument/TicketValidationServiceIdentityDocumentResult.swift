//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct ServiceIdentityRequestResult {
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESCBC: [JSONWebKey]
	let validationServiceEncKeyJwkSetForRSAOAEPWithSHA256AESGCM: [JSONWebKey]
	let validationServiceSignKeyJwkSet: [JSONWebKey]
}
