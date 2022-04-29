//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	JSON
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static func digitalCovid19Certificate(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .dcc,
			paths: ["version", "v1", "dcc"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json",
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 14)
			]
		)
	}

}
