//
// 🦠 Corona-Warn-App
//

import Foundation

struct ServiceIdentityDocument: Codable {
	let id: String
	let verificationMethod: [VerificationMethod]
	let service: [DecoratorServiceModel]?
}
