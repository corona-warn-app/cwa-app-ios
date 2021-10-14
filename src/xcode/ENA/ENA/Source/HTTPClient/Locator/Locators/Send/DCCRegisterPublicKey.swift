//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func dccRegisterPublicKey(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .dcc,
			paths: ["version", "v1", "publicKey"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json",
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 14)
			]
		)
	}

}
