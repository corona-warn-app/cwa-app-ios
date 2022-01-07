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
		self.type = .caching()
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ValidationOnboardedCountriesModel>()
	}

	// MARK: - Protocol Resource

	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ValidationOnboardedCountriesModel>
	typealias CustomError = Error // no CustomError at the moment

	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ValidationOnboardedCountriesModel>

}
