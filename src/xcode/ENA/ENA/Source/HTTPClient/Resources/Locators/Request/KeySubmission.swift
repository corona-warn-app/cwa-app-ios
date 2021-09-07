//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func keySubmission(
		payload: SubmissionPayload,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		let fakePadding = isFake ? String.getRandomString(of: 36) : ""
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys"],
			method: .post,
			defaultHeaders: [payload.tan: "cwa-authorization", fake: "cwa-fake", fakePadding: "cwa-header-padding"],
			// TODO: "application/x-protobuf" as Content Type?
			// TODO: Body (Protobuf) is missing here
			type: .default
		)
	}

}
