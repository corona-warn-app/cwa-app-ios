//
// 🦠 Corona-Warn-App
//

#if !RELEASE

struct LoadResource {
	let result: Result<Any, Error>
	let willLoadResource: ((Any) -> Void)?
}

class RestServiceProviderStub: RestServiceProviding {

	init(
		loadResources: [LoadResource]
	) {
		self.loadResources = loadResources
	}

	convenience init(results: [Result<Any, Error>]) {
		let _loadResources = results.map {
			LoadResource(result: $0, willLoadResource: nil)
		}
		self.init(loadResources: _loadResources)
	}

	private var loadResources: [LoadResource]
	
	// MARK: Protocol RestServiceProviding

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard !resource.locator.isFake else {
			Log.debug("Fake detected no response given", log: .client)
			if let loadResource = loadResources.first {
				loadResource.willLoadResource?(resource)
			}
			completion(.failure(.fakeResponse))
			return
		}
		if let loadResource = loadResources.first {
			loadResource.willLoadResource?(resource)
			switch loadResource.result {
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
			}
		} else {
			fallBackToDefaultMockLoadResource(resource: resource, completion: completion)
		}
	}

	func cached<R>(
		_ resource: R
	) -> Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>> where R: Resource {
		Log.info("Stub doesn't support cached model access at the moment")
		return .failure(.resourceError(.missingCache))
	}

	func update(_ evaluateTrust: TrustEvaluating) {
		Log.debug("No update supported")
	}
	
	// MARK: Private
	
	private func fallBackToDefaultMockLoadResource<R>(
		resource: R,
		completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let mockedLoadResponse = resource.defaultMockLoadResource else {
			fatalError("no default to fallback to")
		}
		switch mockedLoadResponse.result {
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
		}
	}
}

extension RestServiceProviding where Self == RestServiceProviderStub {
	static func fake() -> RestServiceProviding {
		return RestServiceProviderStub(loadResources: [])
	}
}

#endif
