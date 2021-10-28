//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func submitOnBehalf(
		payload: SubmissionPayload,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let fakePadding = isFake ? String.getRandomString(of: 36) : ""
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "submission-on-behalf"],
			method: .post,
			defaultHeaders: [
				"cwa-authorization": payload.tan,
				"cwa-fake": fake,
				"cwa-header-padding": fakePadding
			]
		)
	}

}
