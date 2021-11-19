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

		switch loadResource.result {
		case .success(let model):
			guard let _model = model as? R.Receive.ReceiveModel else {
				fatalError("model does not have the correct type.")
			}
			completion(.success(_model))
		case .failure(let error):
			guard let _error = error as? ServiceError<R.CustomError> else {
				fatalError("error does not have the correct type.")
			}
			completion(.failure(_error))
		}
		loadResources.removeFirst()
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
