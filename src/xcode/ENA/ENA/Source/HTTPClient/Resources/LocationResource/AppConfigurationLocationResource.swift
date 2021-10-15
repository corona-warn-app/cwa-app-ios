//
// 🦠 Corona-Warn-App
//

import Foundation

struct AppConfigurationLocationResource: LocationResource {

	// MARK: - Init

	init() {
		self.locator = Locator.appConfiguration
		self.type = .caching
	}

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType
}
