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
		self.receiveResource = CBORReceiveResource<CCLConfigurationReceiveModel>()
	}
	
	// MARK: - Protocol Resource
	
	typealias Send = EmptySendResource
	typealias Receive = CBORReceiveResource<CCLConfigurationReceiveModel>
	typealias CustomError = Error
	
	var locator: Locator
	var type: ServiceType
	var sendResource: EmptySendResource
	var receiveResource: CBORReceiveResource<CCLConfigurationReceiveModel>
	var defaultModel: CCLConfigurationReceiveModel? {
			
		guard let url = Bundle.main.url(forResource: "ccl-configuration", withExtension: "bin"),
			  let fallbackBin = try? Data(contentsOf: url) else {
			Log.error("Creating the default model failed due to loading default bin from disc", log: .client)
			return nil
		}
		switch CCLConfigurationReceiveModel.make(with: fallbackBin) {
		case .success(let model):
			return model
		case .failure(let error):
			Log.error("Creating the default model failed due to an decoding error: \(error)", log: .client, error: error)
			return nil
		}
	}
}
