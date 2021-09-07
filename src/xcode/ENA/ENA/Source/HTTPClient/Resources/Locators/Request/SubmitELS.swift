//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func submitELS(
		otpEls: String,
		isFake: Bool
	) -> Locator {
		// TODO: Super special case: Multipart
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .errorLogSubmission,
			paths: ["api", "logs"],
			method: .post,
			defaultHeaders: [otpEls: "cwa-otp", fake: "cwa-fake"]
			// TODO: "application/x-protobuf" as Content Type?
			// TODO: Body (Protobuf) is missing here
		)
	}

}
