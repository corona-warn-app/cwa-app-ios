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
			defaultHeaders: [
				"cwa-otp": otpEls,
				"cwa-fake": fake
			]
		)
	}

}
