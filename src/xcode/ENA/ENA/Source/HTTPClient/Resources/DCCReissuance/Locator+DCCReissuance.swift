//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	JSON
	// receive:	JSON
	// type:	default
	// comment:

	static var dccReissuance: Locator {
		return Locator(
			endpoint: .dccRecertify,
			paths: ["api", "certify", "v2", "reissue"],
			method: .post,
			defaultHeaders: [
				"Content-Type": "application/json"
			]
		)
	}
}
