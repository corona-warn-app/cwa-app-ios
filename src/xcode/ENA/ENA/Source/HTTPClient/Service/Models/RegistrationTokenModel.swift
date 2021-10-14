//
// 🦠 Corona-Warn-App
//

import Foundation

protocol PaddingJsonResource: Encodable {
	var requestPadding: String { get set }
	var paddingCount: String { get }
}

extension PaddingJsonResource {

	var paddingCount: String {
		let maxRequestPayloadSize = 250
		guard let paddedData = try? JSONEncoder().encode(self) else {
			fatalError("padding count error")
		}
		let paddingSize = maxRequestPayloadSize - paddedData.count
		return String.getRandomString(of: max(0, paddingSize))
	}
}

struct RegistrationTokenModel: PaddingJsonResource {

	init(registrationToken: String) {
		self.registrationToken = registrationToken
	}

	let registrationToken: String
	var requestPadding: String = ""
//	let publicKey: String?

}

struct KeyModel: PaddingJsonResource {

	let key: String
	let keyType: String
	// ToDo optional dob?
	var requestPadding: String = ""

}
