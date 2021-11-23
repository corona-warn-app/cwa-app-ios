//
// 🦠 Corona-Warn-App
//

import Foundation

/**
This is the default implementation of a service and serves not only as default implementation. It provides some hooks to the generic resources and make different service implementations possible.

 When calling a function of a service, it traverses this hook and in the implementations of the functions of the protocol. Here we do some stuff every service implementation normally should do and prevent so code duplication (e.g. setting the standard http request headers).
When a service wants a more specific handling, it can just implements the protocols functions and inherits from start the implementation of here.
*/
extension Service {
	
	func urlRequest<S, R>(
		_ locator: Locator,
		_ sendResource: S,
		_ receiveResource: R
	) -> Result<URLRequest, ResourceError> where S: SendResource, R: ReceiveResource {
		let endpointURL = locator.endpoint.url(environment.currentEnvironment())
		let url = locator.paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		urlRequest.httpMethod = locator.method.rawValue
		switch sendResource.encode() {
		case let .success(data):
			urlRequest.httpBody = data
		case let .failure(error):
			return .failure(error)
		}

		locator.headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		customHeaders(receiveResource, locator)?.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}
		return .success(urlRequest)
	}

	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch urlRequest(resource.locator, resource.sendResource, resource.receiveResource) {
		case let .failure(resourceError):
			completion(.failure(customError(in: resource, for: .transportationError(resourceError))))
		case let .success(request):
			session.dataTask(with: request) { bodyData, response, error in
				if let error = error {
					completion(.failure(customError(in: resource, for: .transportationError(error))))
					return
				}

				guard !resource.locator.isFake else {
					Log.debug("Fake detected no response given", log: .client)
					completion(.failure(customError(in: resource, for: .fakeResponse)))
					return
				}

				guard let response = response as? HTTPURLResponse else {
					Log.debug("Error: \(error?.localizedDescription ?? "no reason given")", log: .client)
					completion(.failure(customError(in: resource, for: .invalidResponseType)))
					return
				}

				#if DEBUG
				Log.debug("URL Response \(response.statusCode)", log: .client)
				#endif

				switch response.statusCode {
				case 200, 201:
					decodeModel(resource, bodyData, response, completion)
				case 204:
					guard resource.receiveResource is EmptyReceiveResource else {
						completion(.failure(customError(in: resource, for: .invalidResponse)))
						return
					}
					decodeModel(resource, bodyData, response, completion)
				case 304:
					cached(resource, completion)
				default:
					completion(.failure(customError(in: resource, for: .unexpectedServerError(response.statusCode))))
				}
			}.resume()
		}
	}

	func decodeModel<R>(
		_ resource: R,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.receiveResource.decode(bodyData) {
		case .success(let model):
			completion(.success(model))
		case .failure(let resourceError):
			completion(.failure(customError(in: resource, for: .resourceError(resourceError))))
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		completion(.failure(customError(in: resource, for: .resourceError(.notModified))))
	}
	
	func customHeaders<R>(
		_ receiveResource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource {
		return nil
	}
}
