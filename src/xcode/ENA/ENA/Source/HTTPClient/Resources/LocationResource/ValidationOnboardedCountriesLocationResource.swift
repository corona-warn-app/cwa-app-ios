//
// 🦠 Corona-Warn-App
//

import Foundation

struct ValidationOnboardedCountriesLocationResource: LocationResource {

	// MARK: - Init

	init(
		isFake: Bool
	) {
		self.locator = Locator.validationOnboardedCountries(isFake: isFake)
		self.type = .default
	}

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType
}
