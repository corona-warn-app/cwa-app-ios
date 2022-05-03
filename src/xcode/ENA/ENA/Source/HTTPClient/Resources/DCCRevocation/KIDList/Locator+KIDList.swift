//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var kidList: Locator {
		return Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "dcc-rl", "kid"],
			method: .get
		)
	}
}
