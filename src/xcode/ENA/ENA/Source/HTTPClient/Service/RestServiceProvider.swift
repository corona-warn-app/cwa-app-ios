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
		self.dynamicPinningRestService = DynamicPinningRestService(environment: environment, session: session, jwkSet: jwkSet)
		self.disabledPinningRestService = DisabledPinningRestService(environment: environment, session: session)
	}

	#if DEBUG

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
		self.standardRestService = StandardRestService(environment: environment, session: session)
		self.cachedRestService = CachedRestService(environment: environment, session: session, cache: KeyValueCacheFake())
		self.wifiOnlyRestService = WifiOnlyRestService(environment: environment, session: session)
		self.dynamicPinningRestService = DynamicPinningRestService(environment: environment, session: session)
		self.disabledPinningRestService = DisabledPinningRestService(environment: environment, session: session)
	}

	#endif

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
		case .dynamicPinning:
			/// use lock to make sure we are not updating dynamicPinningRestService at the moment
			updateLock.lock()
			dynamicPinningRestService.load(resource, completion)
			updateLock.unlock()
		case .disabledPinning:
			disabledPinningRestService.load(resource, completion)
			
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.type {
		case .caching:
			cachedRestService.cached(resource, completion)
		default:
			Log.error("Cache is not supported by that type of restService")
			completion(.failure(.resourceError(.missingCache)))
		}
	}

	// update evaluation trust - only possible for dynamic pinning at the moment
	func update(_ evaluateTrust: EvaluateTrust) {
		guard let delegate = dynamicPinningRestService.urlSessionDelegate as? CoronaWarnURLSessionDelegate else {
			return
		}

		updateLock.lock()
		delegate.evaluateTrust = evaluateTrust
		updateLock.unlock()
	}

	// MARK: - Private

	private let environment: EnvironmentProviding
	private let optionalSession: URLSession?
	private let standardRestService: StandardRestService
	private let cachedRestService: CachedRestService
	private let wifiOnlyRestService: WifiOnlyRestService
	private let dynamicPinningRestService: DynamicPinningRestService
	private let disabledPinningRestService: DisabledPinningRestService
	private let updateLock: NSLock = NSLock()

}

#if !RELEASE
extension RestServiceProvider {

	var evaluateTrust: EvaluateTrust? {
		guard let delegate = dynamicPinningRestService.urlSessionDelegate as? CoronaWarnURLSessionDelegate else {
			return nil
		}
		return delegate.evaluateTrust
	}

}
#endif
