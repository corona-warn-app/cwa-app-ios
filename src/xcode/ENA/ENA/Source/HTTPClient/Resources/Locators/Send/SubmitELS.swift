//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	xForm multipart
	// receive:
	// type:	xForm Multipart
	// comment:	we don't have a SendResource class for that yet. Boundary is a unique random string per submission
	static func submitELS(
		otpEls: String,
		isFake: Bool,
		boundary: String
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .errorLogSubmission,
			paths: ["api", "logs"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "multipart/form-data; boundary=\(boundary)",
				"cwa-otp": otpEls,
				"cwa-fake": fake
			]
		)
	}

}
