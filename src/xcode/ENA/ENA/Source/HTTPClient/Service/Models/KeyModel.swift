//
// 🦠 Corona-Warn-App
//

import Foundation

struct KeyModel: PaddingResource {
	let key: String
	let keyType: KeyType
	// we might need dob later here
	var requestPadding: String = ""
}

enum KeyType: String, Encodable {
	case teleTan = "TELETAN"
	case qrCode = "QRCode"  // don't know if this is correct right now
}
