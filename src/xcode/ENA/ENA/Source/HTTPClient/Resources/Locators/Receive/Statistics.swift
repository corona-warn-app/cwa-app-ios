//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var statistics: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "stats"],
			method: .get
		)
	}

}
