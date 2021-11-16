//
// 🦠 Corona-Warn-App
//

import Foundation

/**
RestServiceProvider is basically a dispatcher that directs work to the correct service by type.
When calling the loading function, the RestServiceProvider decides which service has to be used by the LocationResource's serviceType. When it passes everything to the ServiceHook and from there to the concrete service implementation.
*/
class RestServiceProvider: RestServiceProviding {

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil,
		cache: KeyValueCaching,
		jwkSet: [Data] = []
	) {
		self.environment = environment
		self.optionalSession = session

		self.restService = StandardRestService(environment: environment, session: session)
		self.cachedService = CachedRestService(environment: environment, session: session, cache: cache)
		self.wifiOnlyService = WifiOnlyRestService(environment: environment, session: session)
		self.dynamicPinningRestService = DynamicPinningRestService(environment: environment, session: session, jwkSet: jwkSet)
	}

	#if DEBUG

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
		self.restService = StandardRestService(environment: environment, session: session)
		self.cachedService = CachedRestService(environment: environment, session: session, cache: KeyValueCacheFake())
		self.wifiOnlyService = WifiOnlyRestService(environment: environment, session: session)
		self.dynamicPinningRestService = DynamicPinningRestService(environment: environment, session: session)
	}

	#endif

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		// dispatch loading to the correct rest service
		switch resource.type {
		case .default:
			restService.load(resource, completion)
		case .caching:
			cachedService.load(resource, completion)
		case .wifiOnly:
			wifiOnlyService.load(resource, completion)
		case .retrying:
			Log.error("Not yet implemented")
		case .dynamicPinning:
			/// use lock to make sure we are not updating dynamicPinningRestService at the moment
			updateLock.lock()
			dynamicPinningRestService.load(resource, completion)
			updateLock.unlock()
		}
	}

	/// update jwkSet for pinning, use a lock to ensure dynamicPinningRestService access
	func update(jwkSet: [Data]) {
		updateLock.lock()
		dynamicPinningRestService.session.invalidateAndCancel()
		dynamicPinningRestService = DynamicPinningRestService(environment: environment, session: optionalSession, jwkSet: jwkSet)
		updateLock.unlock()
	}

	// MARK: - Private

	private let environment: EnvironmentProviding
	private let optionalSession: URLSession?
	private let restService: StandardRestService
	private let cachedService: CachedRestService
	private let wifiOnlyService: WifiOnlyRestService
	private var dynamicPinningRestService: DynamicPinningRestService
	private let updateLock: NSLock = NSLock()

}
