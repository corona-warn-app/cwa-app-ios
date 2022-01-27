//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	ProtoBuf SAP_Internal_Stats_Statistics
	// type:	caching
	// comment:
	static var statistics: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "stats"],
			method: .get
		)
	}

}
