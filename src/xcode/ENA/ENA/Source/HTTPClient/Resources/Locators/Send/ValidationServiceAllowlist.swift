//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Nothing
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static func validationServiceAllowlist() -> Locator {
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "validation-services"],
			method: .get
		)
	}
}
