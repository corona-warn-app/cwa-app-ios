//
// 🦠 Corona-Warn-App
//

import Foundation

protocol RestServiceProviding {
	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource
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
	) where T: Resource {
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

	private let restService: DefaultRestService
	private let cachedRestService: CachedRestService
	private let wifiRestService: WifiOnlyRestService

}
