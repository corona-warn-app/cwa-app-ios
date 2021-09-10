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
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys", "registrationToken"],
			method: .post,
			defaultHeaders: [fake: "cwa-fake", "": "cwa-header-padding"]
			// TODO: Body is missing here
		)
	}

}
