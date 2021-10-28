//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func digitalCovid19Certificate(
		registrationToken: String,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .dcc,
			paths: ["version", "v1", "dcc"],
			method: .post,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 14)
			]
		)
	}

}
