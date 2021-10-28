//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func testResult(
		registrationToken: String,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "testresult"],
			method: .post,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 7)
			]
		)
	}

}
