//
// 🦠 Corona-Warn-App
//

import Foundation

struct DccPublicKeyLocationResource: LocationResource {

	// MARK: - Init

	init(
		isFake: Bool
	) {
		self.locator = Locator.dccRegisterPublicKey(isFake: isFake)
		self.type = .default
	}

	// MARK: - Protocol LocationResource

	var locator: Locator

	var type: ServiceType
}
