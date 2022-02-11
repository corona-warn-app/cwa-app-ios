//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Nothing
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static var allowList: Locator {
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "validation-services"],
			method: .get
		)
	}
}
