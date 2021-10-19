//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var dscList: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "dscs"],
			method: .get
		)
	}

}
