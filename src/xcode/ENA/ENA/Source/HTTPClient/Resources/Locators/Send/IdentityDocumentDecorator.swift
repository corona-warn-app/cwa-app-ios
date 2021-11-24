//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	JSON
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static func identityDocumentDecorator(url: URL) -> Locator {
		return Locator(
			endpoint: .dynamic(url),
			paths: [],
			method: .get
		)
	}

}
