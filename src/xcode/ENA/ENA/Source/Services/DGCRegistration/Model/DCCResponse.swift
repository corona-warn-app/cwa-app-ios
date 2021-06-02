////
// 🦠 Corona-Warn-App
//

import Foundation

struct DCCResponse: Codable {
	// data encryption key, base64 encoded
	let dek: String
	// COSE-Object, base64 encoded
	let dcc: String
}
