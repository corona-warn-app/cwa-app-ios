//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	JSON
	static func availableDays(
		country: String
	) -> Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys", "country", country, "date"],
			method: .get
		)
	}

}
