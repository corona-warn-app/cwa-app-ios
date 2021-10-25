//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeyModel: PaddingResource {
	// Don't change these names, they are used as keys for a http request.
	let key: String
	let keyType: KeyType
	let keyDob: String?

	var requestPadding: String = ""
}

enum KeyType: String, Encodable {
	case teleTan = "TELETAN"
	case qrCode = "QRCode"
	case guid = "GUID"
}
