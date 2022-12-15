////
// 🦠 Corona-Warn-App
//

import Foundation

struct PPACToken {
	init(apiToken: String, previousApiToken: String = "", deviceToken: String) {
		self.apiToken = apiToken
		self.previousApiToken = previousApiToken
		self.deviceToken = deviceToken
	}
	let apiToken: String
	let previousApiToken: String
	let deviceToken: String
}
