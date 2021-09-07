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
			defaultHeaders: [fake: "cwa-fake", String.getRandomString(of: 7): "cwa-header-padding"]
			// TODO: Body is missing here
		)
	}

}
