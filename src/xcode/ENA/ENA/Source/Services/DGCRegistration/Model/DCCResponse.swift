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

extension DCCResponse: Equatable {
	static func == (lhs: DCCResponse, rhs: DCCResponse) -> Bool {
		return lhs.dcc == rhs.dcc && lhs.dek == rhs.dek
	}
}

struct DCC500Response: Codable {
	let reason: String
}
