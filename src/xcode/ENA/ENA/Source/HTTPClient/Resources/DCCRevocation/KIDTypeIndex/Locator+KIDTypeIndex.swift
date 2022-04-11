//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
	
	init(
		kid: String,
		hashType: String
	) {
		self.init(
			endpoint: .distribution,
			paths: ["version", "v1", "dcc-rl", "\(kid)\(hashType)", "index"],
			method: .get
		)
	}
}
