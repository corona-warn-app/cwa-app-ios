//
// 🦠 Corona-Warn-App
//

#if !RELEASE

struct LoadResource {

	init(
		result: @escaping @autoclosure () throws -> Result<Any, Error>,
		willLoadResource: ((Any) -> Void)?
	) {
		self.result = result
		self.willLoadResource = willLoadResource
	}

	let result: () throws -> Result<Any, Error>
	let willLoadResource: ((Any) -> Void)?
}

class RestServiceProviderStub: RestServiceProviding {

	init(
		loadResources: [LoadResource] = [],
		cacheResources: [LoadResource] = [],
		isFakeResourceLoadingActive: Bool = false
	) {
		self.loadResources = loadResources
		self.cacheResources = cacheResources
		self.isFakeResourceLoadingActive = isFakeResourceLoadingActive
	}

	convenience init(results: [Result<Any, Error>]) {
		let _loadResources = results.map {
			LoadResource(result: $0, willLoadResource: nil)
		}
		self.init(loadResources: _loadResources)
	}
	
	convenience init(cachedResults: [Result<Any, Error>]) {
		let _loadResources = cachedResults.map {
			LoadResource(result: $0, willLoadResource: nil)
		}
		self.init(cacheResources: _loadResources)
	}

	let isWifiOnlyActive: Bool = true

	private var loadResources: [LoadResource]
	private var cacheResources: [LoadResource]
	private var isFakeResourceLoadingActive: Bool

	// MARK: Protocol RestServiceProviding

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard !resource.locator.isFake else {
			Log.debug("Fake detected no response given", log: .client)
			if let loadResource = loadResources.first,
			   isFakeResourceLoadingActive {
				loadResource.willLoadResource?(resource)
				loadResources.removeFirst()
			}
			completion(.failure(.fakeResponse))
			return
		}
		if let loadResource = loadResources.first {
			loadResource.willLoadResource?(resource)
			switch try? loadResource.result() {
			case .success(let model):
				guard let _model = model as? R.Receive.ReceiveModel else {
					fallBackToDefaultMockLoadResource(resource: resource, completion: completion)
					return
				}
				// we need to remove the first resource calling the completion otherwise the second call can enter before removeFirst()
				loadResources.removeFirst()
				completion(.success(_model))
			case .failure(let error):
				guard let _error = error as? ServiceError<R.CustomError> else {
					fallBackToDefaultMockLoadResource(resource: resource, completion: completion)
					return
				}
				loadResources.removeFirst()
				completion(.failure(_error))
			case .none:
				fatalError("Resource must provide result")
			}
		} else {
			fallBackToDefaultMockLoadResource(resource: resource, completion: completion)
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let cacheResource = cacheResources.first else {
			completion(.failure(.resourceError(.missingCache)))
			return
		}
		cacheResources.removeFirst()
		
		switch try? cacheResource.result() {
		case .success(let model):
			guard let _model = model as? R.Receive.ReceiveModel else {
				fatalError("Could not cast to receive model.")
			}
			return completion(.success(_model))
		case .failure(let error):
			guard let _error = error as? ServiceError<R.CustomError> else {
				fatalError("Could not cast to custom error.")
			}
			return completion(.failure(_error))
		case .none:
			fatalError("Resource must provide result")
		}
	}

	func resetCache<R>(
		for resource: R
	) where R: Resource {
		fatalError("Not supported")
	}

	func update(_ evaluateTrust: TrustEvaluating) {
		Log.debug("No update supported")
	}

	func updateWiFiSession(wifiOnly: Bool) {
		Log.debug("not supported in stub")
	}

	func isDisabled(_ identifier: String) -> Bool {
		Log.debug("not supported in stub")
		return false
	}

	func disable(_ identifier: String) {
		Log.debug("not supported in stub")
	}

	func enable(_ identifier: String) {
		Log.debug("not supported in stub")
	}

	// MARK: Private
	
	private func fallBackToDefaultMockLoadResource<R>(
		resource: R,
		completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let mockedLoadResponse = resource.defaultMockLoadResource else {
			fatalError("no default to fallback to")
		}
		switch try? mockedLoadResponse.result() {
		case .success(let model):
			guard let model = model as? R.Receive.ReceiveModel else {
				fatalError("model does not have the correct type.")
			}
			completion(.success(model))
		case .failure(let error):
			guard let error = error as? ServiceError<R.CustomError> else {
				fatalError("error does not have the correct type.")
			}
			completion(.failure(error))
		case .none:
			fatalError("Resource must provide result")
		}
	}
}

extension RestServiceProviding where Self == RestServiceProviderStub {
	static func fake() -> RestServiceProviding {
		return RestServiceProviderStub(loadResources: [])
	}
}

#endif
