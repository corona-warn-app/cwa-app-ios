//
// 🦠 Corona-Warn-App
//

import Foundation


/**
This is a special default implementation of Service and serves not only as default implementation but also as a hook to the generic resources and different service implementations.
When calling a function of a service, it traverses this hook and in the implementations of the functions of the protocol. Here we do some stuff every service implementation normally should do and prevent so code duplication (e.g. setting the standard http request headers).
When a service wants a more specific handling, it can just implements the protocols functions and inherits from start the implementation of here.
*/
extension Service {
	
	func urlRequest<S, R>(
		_ locator: Locator,
		_ sendResource: S? = nil,
		_ receiveResource: R
	) -> Result<URLRequest, ResourceError> where S: SendResource, R: ReceiveResource {
		let endpointURL = locator.endpoint.url(environment.currentEnvironment())
		let url = locator.paths.reduce(endpointURL) { result, component in
			result.appendingPathComponent(component, isDirectory: false)
		}
		var urlRequest = URLRequest(url: url)
		switch sendResource?.encode() {
		case let .success(data):
			urlRequest.httpBody = data
		case let .failure(error):
			return .failure(error)
		case .none:
			// We have no body to set.
			break
		}

		locator.headers.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}

		customHeaders(receiveResource, locator)?.forEach { key, value in
			urlRequest.setValue(value, forHTTPHeaderField: key)
		}
		return .success(urlRequest)
	}

	func load<S, R>(
		_ locator: Locator,
		_ sendResource: S?,
		_ receiveResource: R,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where S: SendResource, R: ReceiveResource {
		
		switch urlRequest(locator, sendResource, receiveResource) {
		case let .failure(resourceError):
			completion(.failure(.serverError(resourceError)))
		case let .success(request):
			session.dataTask(with: request) { bodyData, response, error in
				guard error == nil,
					  let response = response as? HTTPURLResponse else {
					Log.debug("Error: \(error?.localizedDescription ?? "no reason given")", log: .client)
					completion(.failure(.serverError(error)))
					return
				}
				#if DEBUG
				Log.debug("URL Response \(response.statusCode)", log: .client)
				#endif
				switch response.statusCode {
				case 200, 201:
					decodeModel(receiveResource, locator, bodyData, response, completion)

				case 202...204:
					completion(.success(nil))

				case 304:
					cached(receiveResource, locator, completion)

				default:
					completion(.failure(.unexpectedResponse(response.statusCode)))
				}
			}.resume()
		}
	}

	func decodeModel<R>(
		_ resource: R,
		_ locator: Locator,
		_ bodyData: Data? = nil,
		_ response: HTTPURLResponse? = nil,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where R: ReceiveResource {
		switch resource.decode(bodyData) {
		case .success(let model):
			completion(.success(model))
		case .failure(let resourceError):
			completion(.failure(.resourceError(resourceError)))
		}
	}

	func cached<R>(
		_ resource: R,
		_ locator: Locator,
		_ completion: @escaping (Result<R.ReceiveModel?, ServiceError>) -> Void
	) where R: ReceiveResource {
		completion(.failure(.resourceError(.notModified)))
	}
	
	func customHeaders<R>(
		_ resource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource {
		return nil
	}
}
