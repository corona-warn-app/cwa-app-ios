//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

struct VerificationMethod: Codable {
	// Identifier of the service identity document
	let id: String
	// Type of the verification method
	let type: String
	// Controller of the verification method
	let controller: String
	let publicKeyJwk: JSONWebKey?
	// An array of strings referencing id attributes of other verification methods. As this parameter is optional, it may be defaulted to an empty array
	let verificationMethods: [String]?
}
