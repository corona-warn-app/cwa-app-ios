//
// 🦠 Corona-Warn-App
//

import Foundation

struct CCLConfigurationResource: Resource {
	
	// MARK: - Init
	
	init(
		isFake: Bool = false
	) {
		self.locator = .CCLConfiguration(isFake: isFake)
		self.type = .caching(
			Set<CacheUsePolicy>([.loadOnlyOnceADay])
		)
		self.sendResource = EmptySendResource()
		self.receiveResource = CBORReceiveResource<ModelWithCache<CCLConfigurationReceiveModel>>()
	}
	
	// MARK: - Protocol Resource
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<ModelWithCache<CCLConfigurationReceiveModel>>
	typealias CustomError = Error
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<ModelWithCache<CCLConfigurationReceiveModel>>
	var defaultModel: CCLConfigurationReceiveModel? {
		let fallbackBin = Data()
		return CCLConfigurationReceiveModel(someVar: fallbackBin)
	}
}
