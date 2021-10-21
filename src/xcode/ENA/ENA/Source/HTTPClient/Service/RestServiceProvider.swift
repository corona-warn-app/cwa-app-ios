//
// 🦠 Corona-Warn-App
//

import Foundation

/**
The RestServiceProvider is the service called from "outside" and is initialized in regular only once with the given Environments.
When calling the loading function, the RestServiceProvider decides which service has to be used by the LocationResource's serviceType. When it passes everything to the ServiceHook and from there to the concrete service implementation.
*/
class RestServiceProvider: RestServiceProviding {

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.restService = StandardRestService(environment: environment)
		self.cachedRestService = CachedRestService(environment: environment)
		self.wifiRestService = WifiOnlyRestService(environment: environment)
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
			cachedRestService.load(resource.locator, resource.sendResource, resource.receiveResource, completion)
		case .wifiOnly:
			wifiRestService.load(resource.locator, resource.sendResource, resource.receiveResource, completion)
		case .retrying:
			fatalError("missing service - NYD")
		}
	}

	private let restService: StandardRestService
	private let cachedRestService: CachedRestService
	private let wifiRestService: WifiOnlyRestService

}
