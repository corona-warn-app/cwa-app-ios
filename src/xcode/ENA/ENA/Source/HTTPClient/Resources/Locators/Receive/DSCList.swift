//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	??? - check if it's still in use, otherwise remove
	// type:
	// comment:
	static var dscList: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "ehn-dgc", "dscs"],
			method: .get
		)
	}

}
