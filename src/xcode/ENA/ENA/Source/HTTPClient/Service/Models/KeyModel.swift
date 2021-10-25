//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeyModel: PaddingResource {
	let key: String
	let type: KeyType
	let dateOfBirthKey: String?
}

enum KeyType: String, Encodable {
	case teleTan = "TELETAN"
	case qrCode = "QRCode"  // don't know if this is correct right now
}
