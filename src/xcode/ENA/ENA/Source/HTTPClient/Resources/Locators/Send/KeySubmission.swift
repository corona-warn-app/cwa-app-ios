//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	ProtoBuf SAP_Internal_SubmissionPayload
	// receive:	Empty
	// type:
	// comment:	Custom error handling required
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
			defaultHeaders: [
				"Content-Type": "application/x-protobuf",
				"cwa-authorization": payload.tan,
				"cwa-fake": fake,
				"cwa-header-padding": fakePadding
			]
		)
	}

}
