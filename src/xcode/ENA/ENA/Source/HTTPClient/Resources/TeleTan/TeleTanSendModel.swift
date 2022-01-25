//
// 🦠 Corona-Warn-App
//

import Foundation

struct TeleTanSendModel: PaddingResource {

	// MARK: - Init

	init(
		key: String,
		keyType: KeyType,
		keyDob: String? = nil
	) {
		self.key = key
		self.keyType = keyType
		self.keyDob = keyDob
	}

	// MARK: - Protocol PaddingResource

	var requestPadding: String = ""

	// MARK: - Public

	// MARK: - Internal

	// Don't change these names, they are used as keys for a http request.
	let key: String
	let keyType: KeyType
	let keyDob: String?

}

enum KeyType: String, Encodable {
	case teleTan = "TELETAN"
	case qrCode = "QRCode"
	case guid = "GUID"
}
