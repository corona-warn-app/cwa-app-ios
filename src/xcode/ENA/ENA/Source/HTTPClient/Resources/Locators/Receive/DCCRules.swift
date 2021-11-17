//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	JSON Rule - attention special handling might be required here
	// type:	caching
	// comment:
	static func DCCRules(
		rulePath: String,
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", rulePath],
			method: .get,
			defaultHeaders: [
				"cwa-fake": fake,
				"cwa-header-padding": String.getRandomString(of: 14)
			]
		)
	}

}
