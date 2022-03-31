//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	SAPDownloadedPackage
	// type:	caching
	// comment:
	static func CCLConfiguration(
		isFake: Bool
	) -> Locator {
		let fake = String(isFake ? 1 : 0)
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ccl", "config-v2"],
			method: .get,
			defaultHeaders: [
				"cwa-fake": fake
			]
		)
	}

}
