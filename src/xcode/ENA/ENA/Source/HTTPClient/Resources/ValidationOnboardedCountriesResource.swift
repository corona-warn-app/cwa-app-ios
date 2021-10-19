//
// 🦠 Corona-Warn-App
//

import Foundation

struct ValidationOnboardedCountriesResource: Resource {

	// MARK: - Init

	init(
		isFake: Bool = false
	) {
		self.locator = .validationOnboardedCountries(isFake: isFake)
		self.type = .caching
		self.sendResource = EmptySendResource<Any>()
		self.receiveResource = EmptyReceiveResource<Any>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource<Any>
	typealias Receive = EmptyReceiveResource<Any>

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource<Any>
	var receiveResource: EmptyReceiveResource<Any>

}
