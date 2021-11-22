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

	func update(_ evaluateTrust: EvaluateTrust) {
		Log.debug("No update supported")
	}

}

extension RestServiceProviding where Self == RestServiceProviderStub {
	static func fake() -> RestServiceProviding {
		return RestServiceProviderStub(loadResources: [])
	}
}

#endif
