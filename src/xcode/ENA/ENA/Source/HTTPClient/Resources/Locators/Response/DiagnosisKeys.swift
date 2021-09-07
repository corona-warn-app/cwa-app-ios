//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static func diagnosicKeys(
		day: String,
		country: String
	) -> Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "diagnosis-keys", "country", country, "date", day],
			method: .get,
			type: .retrying
		)
	}

}
