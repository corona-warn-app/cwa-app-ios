//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Just a Protocol where a service has to implement the load method.
*/
protocol RestServiceProviding {

	func load<S, R>(
		_ locationResource: LocationResource,
		_ sendResource: S?,
		_ receiveResource: R,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where S: SendResource, R: ReceiveResource
}

/**
The RestServiceProvider is the service called from "outside" and is initialized in regular only once with the given Environments.
When calling the loading function, the RestServiceProvider decides which service has to be used by the LocationResource's serviceType. When it passes everything to the ServiceHook and from there to the concrete service implementation.
*/
class RestServiceProvider: RestServiceProviding {

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.restService = DefaultRestService(environment: environment)
		self.cachedRestService = CachedRestService(environment: environment)
		self.wifiRestService = WifiOnlyRestService(environment: environment)
	}

	func load<S, R>(
		_ locationResource: LocationResource,
		_ sendResource: S? = nil,
		_ receiveResource: R,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where S: SendResource, R: ReceiveResource {
		switch locationResource.type {
		case .default:
			restService.load(locationResource.locator, sendResource, receiveResource, completion)
		case .caching:
			cachedRestService.load(locationResource.locator, sendResource, receiveResource, completion)
		case .wifiOnly:
			wifiRestService.load(locationResource.locator, sendResource, receiveResource, completion)

		case .retrying:
			fatalError("missing service - NYD")
//			restService.load(resource: resource, completion: completion)
		}
	}

	private let restService: DefaultRestService
	private let cachedRestService: CachedRestService
	private let wifiRestService: WifiOnlyRestService

}
