//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Nothing
	// receive:	JSON
	// type:	default
	// comment:	Custom error handling required
	static func serviceIdentityDocumentValidationDecorator(url: URL) -> Locator {
		return Locator(
			endpoint: .dynamic(url),
			paths: [],
			method: .get
		)
	}
}
