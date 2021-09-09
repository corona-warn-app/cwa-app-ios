//
// 🦠 Corona-Warn-App
//

import Foundation

protocol RestServiceProviding {
	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource

	func load<S, R>(
		locationResource: LocationResource,
		sendResource: S?,
		receiveResource: R,
		completion: @escaping () -> Void
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

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		switch resource.type {
		case .default:
			restService.load(resource: resource, completion: completion)
		case .caching:
			cachedRestService.load(resource: resource, completion: completion)

		case .wifiOnly:
			wifiRestService.load(resource: resource, completion: completion)

		case .retrying:
			fatalError("missing service - NYD")
//			restService.load(resource: resource, completion: completion)
		}
	}

	func load<S, R>(
		locationResource: LocationResource,
		sendResource: S?,
		receiveResource: R,
		completion: @escaping () -> Void
	) where S: SendResource, R: ReceiveResource {

	}

	private let restService: DefaultRestService
	private let cachedRestService: CachedRestService
	private let wifiRestService: WifiOnlyRestService

}
