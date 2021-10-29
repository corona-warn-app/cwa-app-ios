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
		session: URLSession? = nil
	) {
		self.restService = StandardRestService(environment: environment, session: session)
	}

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		// dispatch loading to the correct rest service
		switch resource.type {
		case .default:
			restService.load(resource, completion)
		case .caching:
			Log.error("Not yet implemented")
		case .wifiOnly:
			Log.error("Not yet implemented")
		case .retrying:
			Log.error("Not yet implemented")
		}
	}

	// MARK: - Private

	private let restService: StandardRestService

}

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
}

extension RestServiceProviding where Self == RestServiceProviderStub {
	static func fake() -> RestServiceProviding {
		return RestServiceProviderStub(loadResources: [])
	}
}

#endif
