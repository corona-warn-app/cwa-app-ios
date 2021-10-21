//
// 🦠 Corona-Warn-App
//

import Foundation

/**
RestServiceProvider is basically a dispatcher that directs work to the correct service by type.
When calling the loading function, the RestServiceProvider decides which service has to be used by the LocationResource's serviceType. When it passes everything to the ServiceHook and from there to the concrete service implementation.
*/
class RestServiceProvider: RestServiceProviding {

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.restService = StandardRestService(environment: environment)
	}

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel?, ServiceError>) -> Void
	) where R: Resource {
		// dispatch loading to the correct rest service
		switch resource.type {
		case .default:
			restService.load(resource.locator, resource.sendResource, resource.receiveResource, completion)
		case .caching:
			Log.error("Not yet implemented")
		case .wifiOnly:
			Log.error("Not yet implemented")
		case .retrying:
			Log.error("Not yet implemented")
		}
	}

	// MARK: - Private

	private let restService: StandardRestService

}
