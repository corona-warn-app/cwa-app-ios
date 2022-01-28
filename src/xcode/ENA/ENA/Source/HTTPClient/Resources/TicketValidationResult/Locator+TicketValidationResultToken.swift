//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func ticketValidationResultToken(
		resultTokenServiceURL: URL,
		jwt: String
	) -> Locator {
		return Locator(
			endpoint: .dynamic(resultTokenServiceURL),
			paths: [],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json",
				"X-VERSION": "1.0.0",
				"Accept": "application/jwt",
				"Authorization": "Bearer \(jwt)"
			]
		)
	}

}
