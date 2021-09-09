//
// 🦠 Corona-Warn-App
//

import Foundation

protocol RestServiceProviding {

	func load<S, R>(
		_ locationResource: LocationResource,
		_ sendResource: S?,
		_ receiveResource: R,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where S: SendResource, R: ReceiveResource
}

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
