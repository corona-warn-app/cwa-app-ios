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
			failureOrDefaultValueHandling(resource, .invalidRequestError(resourceError), completion)
		case let .success(request):
			session.dataTask(with: request) { bodyData, response, error in
				
				// If there is a transportation error, check if the underlying error is a trust evaluation error and possibly return it.
				if error != nil,
				   let coronaSessionDelegate = session.delegate as? CoronaWarnURLSessionDelegate,
				   let error = coronaSessionDelegate.evaluateTrust.trustEvaluationError,
				   let trustEvaluationError = error as? TrustEvaluationError {
					Log.error("TrustEvaluation failed.", log: .client)
					failureOrDefaultValueHandling(resource, .trustEvaluationError(trustEvaluationError), completion)
					
					// Reset the error to not block future requests.
					// I know, this error state is not a nice solution.
					// If you have an idea how to solve the problem of having a detailed trust evaluation error at this point, without holding the state, feel free to refactor :)
					coronaSessionDelegate.evaluateTrust.trustEvaluationError = nil
					return
				}
				
				// case we have no network.
				if let error = error {
					handleCachePolicyNoNetwork(error, resource, completion)
					return
				}
								
				// case we have a fake.
				guard !resource.locator.isFake else {
					Log.info("Fake detected no response given", log: .client)
					failureOrDefaultValueHandling(resource, .fakeResponse, completion)
					return
				}

				// case we have an invalid response.
				guard let response = response as? HTTPURLResponse else {
					Log.error("Invalid response.", log: .client, error: error)
					failureOrDefaultValueHandling(resource, .invalidResponseType, completion)
					return
				}
				
				// Now we have a response and a valid status code.

				#if DEBUG
				Log.debug("URL Response \(response.statusCode)", log: .client)
				#endif

				// override status code by cache policy and handle it on other way.
				guard !hasCachePolicyStatusCode(resource, response.statusCode) else {
					handleCachePolicyStatusCode(response.statusCode, resource, completion)
					return
				}
				
				// normal status code handling
				switch response.statusCode {
				case 200, 201:
					decodeModel(resource, bodyData, response, completion)
				case 204:
					guard resource.receiveResource is EmptyReceiveResource else {
						Log.error("This is not an EmptyReceiveResource", log: .client)
						failureOrDefaultValueHandling(resource, .invalidResponse, completion)
						return
					}
					decodeModel(resource, bodyData, response, completion)
				case 304:
					cached(resource, completion)
				default:
					failureOrDefaultValueHandling(resource, .unexpectedServerError(response.statusCode), completion)
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
			failureOrDefaultValueHandling(resource, .resourceError(resourceError), completion)
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		Log.info("No caching allowed for current service.", log: .client)
		failureOrDefaultValueHandling(resource, .resourceError(.notModified), completion)
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

	func hasCachePolicyStatusCode<R>(
		_ resource: R,
		_ statusCode: Int
	) -> Bool where R: Resource {
		return false
	}
	
	// MARK: - Internal
	
	/// Before returning the originial error, we look up in the resource if there is some customized error cases.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - serviceError: The error that would be thrown with the fail.
	func customError<R>(
		in resource: R,
		for serviceError: ServiceError<R.CustomError>
	) -> ServiceError<R.CustomError> where R: Resource {
		if let customError = resource.customError(for: serviceError) {
			return .receivedResourceError(customError)
		} else {
			return serviceError
		}
	}
	
	/// Before failing, this checks if the resource has defined a defaultValue so we can call a .success with it instead of failing. If not defaultValue is given, it will fail as normal.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - error: The error that would be thrown with the fail.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
	func failureOrDefaultValueHandling<R>(
		_ resource: R,
		_ error: ServiceError<R.CustomError>,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		// Check if we have default value. If so, return it independent wich error we had
		if let defaultModel = resource.defaultModel {
			Log.info("Found some default value", log: .client)
			completion(.success(defaultModel))
		} else {
			// We don't have a default value. And now check if we want to override the error by a custom error defined in the resource
			Log.error("Found no default value. Will fail now.", log: .client, error: error)
			completion(.failure(customError(in: resource, for: error)))
		}
	}
	
	// MARK: - Private

	/// Handles the noNetwork cache policy: Checks first, if the cache policy is defined. If not, proceed with the transportation error. Otherwise, try to load the cached data. If this fails, we fall back to the the transportation error.
	///
	/// - Parameters:
	///   - error: the no network error
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
	private func handleCachePolicyNoNetwork<R>(
		_ error: Error,
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		
		// Check if we can handle caching policy noNetwork
		guard case let .caching(policies) = resource.type,
			  policies.contains(.noNetwork) else {
				  // Otherwise, fall back to the default
				  Log.info("No cache policy .noNetwork found.", log: .client)
				  failureOrDefaultValueHandling(resource, .transportationError(error), completion)
				  return
		}
		
		// If so, first we check if we have something cached
		if hasCachedData(resource) {
			Log.info("Found some cached data.", log: .client)
			cached(resource, completion)
			return
		}
		// If not, we will fail with the original error
		else {
			Log.info("Found nothing cached.")
			failureOrDefaultValueHandling(resource, .transportationError(error), completion)
			return
		}
	}
	
	// MARK: - Private

	/// Handles the statusCode cache policy. Checks first, if the cache policy is defined. If not, proceed with the invalidResponse error. Otherwise, try to load the cached data. If this fails, we fall back to the the invalidResponse error.
	///
	/// - Parameters:
	///   - statusCode: The status code of the response
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
	private func handleCachePolicyStatusCode<R>(
		_ statusCode: Int,
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		
		// Check if we can handle caching policy handling
		guard case let .caching(policies) = resource.type,
			  policies.contains(.statusCode(statusCode)) else {
				  // Otherwise, fall back to the default
				  Log.error("No cache policy .statusCode found.", log: .client)
				  failureOrDefaultValueHandling(resource, .invalidResponse, completion)
				  return
		}
		
		// If so, first we check if have something cached
		if hasCachedData(resource) {
			Log.info("Found some cached data", log: .client)
			cached(resource, completion)
			return
		}
		// If not, we will fail with the original error
		else {
			Log.info("Found nothing cached.")
			failureOrDefaultValueHandling(resource, .unexpectedServerError(statusCode), completion)
		}
	}
}
