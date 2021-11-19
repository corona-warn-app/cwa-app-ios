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
	private let restService: StandardRestService
	private let cachedService: CachedRestService
	private let wifiOnlyService: WifiOnlyRestService
	private let dynamicPinningRestService: DynamicPinningRestService
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

	private var loadResources: [LoadResource]

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let loadResource = loadResources.first else {
			fatalError("load was called to often.")
		}
		loadResource.willLoadResource?(resource)
		guard !resource.locator.isFake else {
			Log.debug("Fake detected no response given", log: .client)
			completion(.failure(.fakeResponse))
			return
		}

		switch loadResource.result {
		case .success(let model):
			guard let _model = model as? R.Receive.ReceiveModel else {
				fatalError("model does not have the correct type.")
			}
			// we need to remove the first resource calling the completion otherwise the second call can enter before removeFirst()
			loadResources.removeFirst()
			completion(.success(_model))
		case .failure(let error):
			guard let _error = error as? ServiceError<R.CustomError> else {
				fatalError("error does not have the correct type.")
			}
			loadResources.removeFirst()
			completion(.failure(_error))
		}
	}
}
#endif
