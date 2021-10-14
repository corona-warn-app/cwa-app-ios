//
// 🦠 Corona-Warn-App
//

import Foundation

struct RegistrationTokenLocationResource: LocationResource {

	// MARK: - Init

	init(isFake: Bool) {
		self.locator = Locator.registrationToken(isFake: false)
		self.type = .default
	}

	// MARK: - Overrides

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
