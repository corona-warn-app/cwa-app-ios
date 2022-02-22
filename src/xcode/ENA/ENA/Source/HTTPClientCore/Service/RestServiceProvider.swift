//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

/**
RestServiceProvider is basically a dispatcher that directs work to the correct service by type.
When calling the loading function, the RestServiceProvider decides which service has to be used by the LocationResource's serviceType. When it passes everything to the ServiceHook and from there to the concrete service implementation.
*/
class RestServiceProvider: RestServiceProviding {

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil,
		cache: KeyValueCaching,
		jwkSet: [JSONWebKey] = []
	) {
		self.environment = environment
		self.optionalSession = session

		self.standardRestService = StandardRestService(environment: environment, session: session)
		self.cachedRestService = CachedRestService(environment: environment, session: session, cache: cache)
		self.wifiOnlyRestService = WifiOnlyRestService(environment: environment, session: session)
	}

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		// dispatch loading to the correct rest service
		switch resource.type {
		case .default:
			standardRestService.load(resource, completion)
		case .caching:
			cachedRestService.load(resource, completion)
		case .wifiOnly:
			wifiOnlyRestService.load(resource, completion)
		case .retrying:
			Log.error("Not yet implemented")
		}
	}
	
	func cached<R>(
		_ resource: R
	) -> Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>> where R: Resource {
		switch resource.type {
		case .default:
			return standardRestService.cached(resource)
		case .caching:
			return cachedRestService.cached(resource)
		case .wifiOnly:
			return wifiOnlyRestService.cached(resource)
		default:
			Log.error("Cache is not supported by that type of restService")
			return .failure(.resourceError(.missingCache))
		}
	}

	// MARK: - Private

	private let environment: EnvironmentProviding
	private let optionalSession: URLSession?
	private let standardRestService: StandardRestService
	private let cachedRestService: CachedRestService
	private let wifiOnlyRestService: WifiOnlyRestService

}
