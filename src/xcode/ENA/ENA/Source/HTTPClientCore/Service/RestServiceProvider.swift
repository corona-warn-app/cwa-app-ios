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
			#if DEBUG
			if isUITesting {
				standardRestService.load(resource, completion)
				return
			}
			#endif
			cachedRestService.load(resource, completion)
		case .wifiOnly:
			wifiOnlyRestService.load(resource, completion)
		}
	}
	
	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.type {
		case .default:
			standardRestService.cached(resource, completion)
		case .caching:
			cachedRestService.cached(resource, completion)
		case .wifiOnly:
			wifiOnlyRestService.cached(resource, completion)
		}
	}

	func resetCache<R>(
		for resource: R
	) where R: Resource {
		switch resource.type {
		case .default:
			standardRestService.resetCache(for: resource)
		case .caching:
			cachedRestService.resetCache(for: resource)
		case .wifiOnly:
			wifiOnlyRestService.resetCache(for: resource)
		}
	}

#if !RELEASE
	var isWifiOnlyActive: Bool {
		wifiOnlyRestService.isWifiOnlyActive
	}

	func updateWiFiSession(wifiOnly: Bool) {
		wifiOnlyRestService.updateSession(wifiOnly: wifiOnly)
	}

	func isDisabled(_ identifier: String) -> Bool {
		wifiOnlyRestService.isDisabled(identifier)
	}

	func disable(_ identifier: String) {
		wifiOnlyRestService.disable(identifier)
	}

	func enable(_ identifier: String) {
		wifiOnlyRestService.enable(identifier)
	}

#endif

	// MARK: - Private

	private let environment: EnvironmentProviding
	private let optionalSession: URLSession?
	private let standardRestService: StandardRestService
	private let cachedRestService: CachedRestService
	private let wifiOnlyRestService: WifiOnlyRestService

}
