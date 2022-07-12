//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {
	
	init(
		kid: String,
		hashType: String,
		x: String,
		y: String
	) {
		self.init(
			endpoint: .distribution,
			paths: ["version", "v1", "dcc-rl", "\(kid)\(hashType)", "\(x)", "\(y)", "chunk"],
			method: .get
		)
	}
}
