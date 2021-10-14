//
// 🦠 Corona-Warn-App
//

import Foundation

protocol PaddingJsonResource {
	var requestPadding: String { get set }
	var paddingCount: String { get }
}

struct RegistrationTokenModel: Encodable, PaddingJsonResource {

	init(registrationToken: String) {
		self.registrationToken = registrationToken
	}

	let registrationToken: String
//	let publicKey: String?

	var requestPadding: String = ""

	var paddingCount: String {
		let maxRequestPayloadSize = 250
		guard let paddedData = try? JSONEncoder().encode(self) else {
			fatalError("padding count error")
		}
		let paddingSize = maxRequestPayloadSize - paddedData.count
		return String.getRandomString(of: max(0, paddingSize))
	}

}
