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

	// MARK: - Overrides

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
