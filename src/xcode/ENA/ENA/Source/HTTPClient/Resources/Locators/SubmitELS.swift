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
		let forceApiHeader = String(forceApiTokenHeader ? 1 : 0)
		return Locator(
			endpoint: .errorLogSubmission,
			paths: ["api", "logs"],
			method: .post,
			defaultHeaders: [otpEls: "cwa-otp", fake: "cwa-fake", forceApiHeader: "cwa-ppac-ios-accept-api-token"],
			// TODO: "application/x-protobuf" as Content Type?
			// TODO: Body (Protobuf) is missing here
			type: .default
		)
	}

}
