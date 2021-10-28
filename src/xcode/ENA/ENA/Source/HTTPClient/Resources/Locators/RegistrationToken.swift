//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func registrationToken(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .verification,
			paths: ["version", "v1", "registrationToken"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json",
				"cwa-fake": fake,
				"cwa-header-padding": ""
			]
		)
	}

}
