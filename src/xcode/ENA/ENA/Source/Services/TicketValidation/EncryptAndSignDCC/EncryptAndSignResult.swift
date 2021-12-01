//
// 🦠 Corona-Warn-App
//

import Foundation

struct EncryptAndSignResult {
	let encryptedDCCBase64: String
	let encryptionKeyBase64: String
	let signatureBase64: String
	let signatureAlgorithm: String
}
