//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

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
			Log.error("Encoding for send resource data failed.", log: .client)
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

    // swiftlint:disable cyclomatic_complexity
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch urlRequest(resource.locator, resource.sendResource, resource.receiveResource) {
		case let .failure(resourceError):
			Log.error("Creating url request failed.", log: .client)
			completion(.failure(customError(in: resource, for: .invalidRequestError(resourceError))))
		case let .success(request):
			session.dataTask(with: request) { bodyData, response, error in
				
				// If there is a transportation error, check if the underlying error is a trust evaluation error and possibly return it.
				if error != nil,
				   let coronaSessionDelegate = session.delegate as? CoronaWarnURLSessionDelegate,
				   let error = coronaSessionDelegate.evaluateTrust.trustEvaluationError,
				   let trustEvaluationError = error as? TrustEvaluationError {
					Log.error("TrustEvaluation failed.", log: .client)
					completion(.failure(customError(in: resource, for: .trustEvaluationError(trustEvaluationError))))
					
					// Reset the error to not block future requests.
					// I know, this error state is not a nice solution.
					// If you have an idea how to solve the problem of having a detailed trust evaluation error at this point, without holding the state, feel free to refactor :)
					coronaSessionDelegate.evaluateTrust.trustEvaluationError = nil
					return
				}
				
				if let error = error {
					Log.info("No network connection (.transportationError)", log: .client)
					cacheUseCaseHandling(.noNetwork, error, resource, completion)
					return
				}
								
				guard !resource.locator.isFake else {
					Log.info("Fake detected no response given", log: .client)
					completion(.failure(customError(in: resource, for: .fakeResponse)))
					return
				}

				guard let response = response as? HTTPURLResponse else {
					Log.error("Invalid response.", log: .client, error: error)
					completion(.failure(customError(in: resource, for: .invalidResponseType)))
					return
				}

				#if DEBUG
				Log.debug("URL Response \(response.statusCode)", log: .client)
				#endif

				guard hasNoStatusCodeCacheUseCase(resource, response.statusCode) else {
					cacheUseCaseHandling(.statusCode(response.statusCode), nil, resource, completion)
					return
				}

				switch response.statusCode {
				case 200, 201:
					decodeModel(resource, bodyData, response, completion)
				case 204:
					guard resource.receiveResource is EmptyReceiveResource else {
						Log.error("This is not an EmptyReceiveResource", log: .client)
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
		switch resource.receiveResource.decode(bodyData, headers: response?.allHeaderFields ?? [:]) {
		case .success(let model):
			completion(.success(model))
		case .failure(let resourceError):
			Log.error("Decoding for receive resource failed.", log: .client)
			completion(.failure(customError(in: resource, for: .resourceError(resourceError))))
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		Log.info("No caching allowed for current service.", log: .client)
		completion(.failure(customError(in: resource, for: .resourceError(.notModified))))
	}
	
	func hasCachedData<R>(
		_ resource: R
	) -> Bool where R: Resource {
		return false
	}
	
	func customHeaders<R>(
		_ receiveResource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource {
		return nil
	}

	func hasNoStatusCodeCacheUseCase<R>(
		_ resource: R,
		_ statusCode: Int
	) -> Bool where R: Resource {
		return true
	}

	// MARK: - Private

	private func cacheUseCaseHandling<R>(
		_ cachingType: CacheUseCase,
		_ error: Error?,
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		// check the requested caching behavior of the resource
		guard case let .caching(usage) = resource.type,
			  usage.contains(cachingType) else {
				  completion(.failure(.resourceError(ResourceError.missingData)))
				  return
			  }

		// check if a cached resource exists
		if hasCachedData(resource) {
			Log.info("Found some cached data", log: .client)
			cached(resource, completion)
		}
		// otherwise try to get the default value of the resource.
		else if let defaultModel = resource.defaultModel {
			Log.info("Found some default value", log: .client)
			completion(.success(defaultModel))
		}
		// If we still have nothing we return the transportation error.
		else {
			Log.info("No fallback found")
			switch cachingType {
			case .noNetwork:
				guard let error = error else {
					Log.error("no custom error given", log: .client)
					completion(.failure(customError(in: resource, for: .invalidResponse)))
					return
				}
				Log.error("custom error wrapped into a .transportationError", log: .client)
				completion(.failure(customError(in: resource, for: .transportationError(error))))

			case .statusCode(let statusCodes):
				Log.error("Unexpected server error: (\(statusCodes)", log: .client)
				completion(.failure(customError(in: resource, for: .unexpectedServerError(statusCodes))))
			}
		}
	}


}
