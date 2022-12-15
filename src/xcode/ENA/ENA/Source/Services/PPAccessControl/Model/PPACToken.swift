////
// 🦠 Corona-Warn-App
//

import Foundation

struct PPACToken {
	
	// MARK: - Init
	
	init(apiToken: String, previousApiToken: String, deviceToken: String) {
		self.apiToken = apiToken
		self.previousApiToken = previousApiToken
		self.deviceToken = deviceToken
	}
	
	// MARK: - Internal

	let apiToken: String
	let previousApiToken: String
	let deviceToken: String
}
