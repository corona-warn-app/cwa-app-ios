//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	JSON
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static func testResult(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .verification,
			paths: ["version", "v1", "testresult"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json",
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 7)
			]
		)
	}

}
