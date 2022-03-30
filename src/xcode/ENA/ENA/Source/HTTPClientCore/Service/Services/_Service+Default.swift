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

	func receiveModelToInterruptLoading<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		completion(.failure(ServiceError.noReceiveModelToInterruptLoading))
	}

    // swiftlint:disable cyclomatic_complexity
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {

		// check if we interrupt loading and return directly a model
		receiveModelToInterruptLoading(resource, { result in
			switch result {

			case .success(let receiveModel):
				completion(.success(receiveModel))
			case .failure(let serviceError):
				if case .noReceiveModelToInterruptLoading = serviceError {
					// This is a special case and we ignore the previous failure and continue loading. Equals a not found model.
					break
				} else {
					completion(.failure(serviceError))
				}
			}
		})

		// Save up the retryCount for our resource. Used later then.
		self.resourcesRetries[resource.locator.uniqueIdentifier] = resource.retryingCount

		// load data from the server
		switch urlRequest(resource.locator, resource.sendResource, resource.receiveResource) {
		case let .failure(resourceError):
			Log.error("Creating url request failed.", log: .client)
			failureOrDefaultValueHandling(resource, .invalidRequestError(resourceError), nil, completion)
		case let .success(request):

			var task: URLSessionDataTask?
			task = session.dataTask(with: request) { [weak self] bodyData, response, error in

				guard let self = self else {
					fatalError("Self should not be nil at this point")
				}
				
				defer {
					if let coronaSessionDelegate = self.session.delegate as? CoronaWarnSessionTaskDelegate,
						  let task = task {
						   coronaSessionDelegate.trustEvaluations[task.taskIdentifier] = nil
					   }
				}
				
				// If there is a transportation error, check if the underlying error is a trust evaluation error and possibly return it.
				if error != nil,
				   let coronaSessionDelegate = self.session.delegate as? CoronaWarnSessionTaskDelegate,
				   let task = task,
				   let trustEvaluationError = coronaSessionDelegate.trustEvaluations[task.taskIdentifier]?.trustEvaluationError {
					Log.error("TrustEvaluation failed.", log: .client)
					self.failureOrDefaultValueHandling(resource, .trustEvaluationError(trustEvaluationError), nil, completion)
					return
				}
				
				// case we have no network.
				if let error = error {
					self.handleNoNetworkCachePolicy(resource, error, completion)
					return
				}
								
				// case we have a fake.
				guard !resource.locator.isFake else {
					Log.info("Fake detected no response given", log: .client)
					self.failureOrDefaultValueHandling(resource, .fakeResponse, nil, completion)
					return
				}

				// case we have an invalid response.
				guard let response = response as? HTTPURLResponse else {
					Log.error("Invalid response.", log: .client, error: error)
					self.failureOrDefaultValueHandling(resource, .invalidResponseType, nil, completion)
					return
				}
				
				// Now we have a response and a valid status code.

				#if DEBUG
				Log.debug("URL Response \(response.statusCode)", log: .client)
				#endif

				// override status code by cache policy and handle it on other way.
				if self.hasStatusCodeCachePolicy(resource, response.statusCode) {
					self.handleStatusCodeCachePolicy(resource, response.statusCode, completion)
					return
				}
				
				// Normal status code handling
				// The codes here are in sync with the one in hasStatusCodeCachePolicy in the CachedRestService - do always sync them!
				switch response.statusCode {
				case 200, 201:
					self.decodeModel(resource, bodyData, response.allHeaderFields, false, completion)
				case 204:
					guard resource.receiveResource is EmptyReceiveResource else {
						Log.error("This is not an EmptyReceiveResource", log: .client)
						self.failureOrDefaultValueHandling(resource, .invalidResponse, nil, completion)
						return
					}
					self.decodeModel(resource, bodyData, response.allHeaderFields, false, completion)
				case 304:
					self.cached(resource, completion)
				default:
					self.failureOrDefaultValueHandling(resource, .unexpectedServerError(response.statusCode), bodyData, completion)
				}
			}
			
			guard let task = task else {
				fatalError("Task cannot be nil at this point.")
			}
			
			// Set the trust evaluation which is executed during the request on the CoronaWarnSessionTaskDelegate.
			if let coronaSessionDelegate = session.delegate as? CoronaWarnSessionTaskDelegate {
				coronaSessionDelegate.trustEvaluations[task.taskIdentifier] = resource.trustEvaluation
			}
						
			task.resume()
		}
	}

	func decodeModel<R>(
		_ resource: R,
		_ bodyData: Data?,
		_ headers: [AnyHashable: Any],
		_ isCachedData: Bool,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.receiveResource.decode(bodyData, headers: headers) {
		case .success(let model):
			// Proofs if we can add the metadata to our model.
			if var modelWithMetadata = model as? MetaDataProviding {
				Log.info("Found a model wich conforms to MetaDataProviding. Adding metadata now.", log: .client)
				modelWithMetadata.metaData.headers = headers
				modelWithMetadata.metaData.loadedFromCache = isCachedData
				if let originalModelWithMetadata = modelWithMetadata as? R.Receive.ReceiveModel {
					Log.debug("Returning now the original model with metadata", log: .client)
					completion(.success(originalModelWithMetadata))
				} else {
					Log.warning("Cast back to R.Receive.ReceiveModel failed. Returning the model without metadata.", log: .client)
					completion(.success(model))
				}
			} else {
				Log.debug("This model does not conforms to MetaDataProviding. Returning plain model.", log: .client)
				completion(.success(model))
			}
		case .failure(let resourceError):
			Log.error("Decoding for receive resource failed.", log: .client)
			failureOrDefaultValueHandling(resource, .resourceError(resourceError), nil, completion)
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		Log.info("No caching allowed for current service.", log: .client)
		failureOrDefaultValueHandling(resource, .resourceError(.notModified), nil, completion)
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

	func hasStatusCodeCachePolicy<R>(
		_ resource: R,
		_ statusCode: Int
	) -> Bool where R: Resource {
		return false
	}
	
	// MARK: - Internal
	
	/// Before returning the original error, we look up in the resource if there is some customized error cases.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - serviceError: The error that would be thrown with the fail.
	func customError<R>(
		in resource: R,
		for serviceError: ServiceError<R.CustomError>,
		_ responseData: Data? = nil
	) -> ServiceError<R.CustomError> where R: Resource {
		if let customError = resource.customError(for: serviceError, responseBody: responseData) {
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
		_ responseData: Data? = nil,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {

		if var resourceRetryingCount = self.resourcesRetries[resource.locator.uniqueIdentifier],
		   resourceRetryingCount > 0 {
			Log.debug("Retry for resource discovered. Retry counter at: \(resourceRetryingCount)", log: .client)

			resourceRetryingCount -= 1
			self.resourcesRetries[resource.locator.uniqueIdentifier] = resourceRetryingCount
			Log.debug("Remaining retries now: \(resourceRetryingCount)", log: .client)
			load(resource, completion)
		} else {
			// Now after all retries exhausted (or we did not had any retry), we check if we can return a default value or not. If so, return it independent which error we had
			if let defaultModel = resource.defaultModel {
				Log.info("Found some default value", log: .client)
				guard var modelWithMetadata = defaultModel as? MetaDataProviding else {
					completion(.success(defaultModel))
					return
				}
				Log.info("Found a defaultModel which conforms to MetaDataProviding. Adding metadata now.", log: .client)
				modelWithMetadata.metaData.loadedFromDefault = true
				guard let originalModelWithMetadata = modelWithMetadata as? R.Receive.ReceiveModel else {
					Log.warning("Cast back to R.Receive.ReceiveModel failed. Returning the model without metadata.", log: .client)
					completion(.success(defaultModel))
					return
				}
				Log.debug("Returning now the original model with metadata", log: .client)
				completion(.success(originalModelWithMetadata))
			} else {
				// We don't have a default value. And now check if we want to override the error by a custom error defined in the resource
				Log.error("Found no default value. Will fail now.", log: .client, error: error)
				// cleanup the retryCount dictionary
				self.resourcesRetries[resource.locator.uniqueIdentifier] = nil
				completion(.failure(customError(in: resource, for: error, responseData)))
			}
		}
	}
	
	// MARK: - Private


	/// Handles the noNetwork cache policy: Checks first, if the cache policy is defined. If not, proceed with the transportation error. Otherwise, try to load the cached data. If this fails, we fall back to the the transportation error.
	///
	/// - Parameters:
	///   - error: the no network error
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
	private func handleNoNetworkCachePolicy<R>(
		_ resource: R,
		_ error: Error,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		
		// Check if we can handle caching policy noNetwork
		guard case let .caching(policies) = resource.type,
			  policies.contains(.noNetwork) else {
			// Otherwise, fall back to the default
			Log.info("No cache policy .noNetwork found.", log: .client)
			failureOrDefaultValueHandling(resource, .transportationError(error), nil, completion)
			return
		}
		
		// If so, first we check if we have something cached
		if hasCachedData(resource) {
			Log.info("Found some cached data.", log: .client)
			cached(resource, completion)
		}
		// If not, we will fail with the original error
		else {
			Log.info("Found nothing cached.")
			failureOrDefaultValueHandling(resource, .transportationError(error), nil, completion)
		}
	}

	/// Handles the statusCode cache policy. Checks first, if the cache policy is defined. If not, proceed with the invalidResponse error. Otherwise, try to load the cached data. If this fails, we fall back to the the invalidResponse error.
	///
	/// - Parameters:
	///   - statusCode: The status code of the response
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
	private func handleStatusCodeCachePolicy<R>(
		_ resource: R,
		_ statusCode: Int,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		
		// We do not need to check here if the policy is supported, because we do it already right before the call if this function (see hasStatusCodeCachePolicy).
		
		// First we check if have something cached
		if hasCachedData(resource) {
			Log.info("Found some cached data", log: .client)
			cached(resource, completion)
		}
		// If not, we will fail with the original error
		else {
			Log.info("Found nothing cached.")
			failureOrDefaultValueHandling(resource, .unexpectedServerError(statusCode), nil, completion)
		}
	}

//	/// Handles the possible retry mechanism: Calls the result which we pass inside. If the result succeeds, we call immediately the completion. If the result fails, we first check if we want to retry the download and then if we have some attempts left to retry. If so, we call load() again. Otherwise, we call again the failureOrDefaultValueHandling() to return a possibly a default model or not.
//	///
//	/// - Parameters:
//	///   - resource: Generic ("R") object and normally of type ReceiveResource. It is where the retry and default model is defined.
//	///   - result: Result of a func call where we try to retrieve a model or get a fail.
//	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call.
//	private func handleRetry<R>(
//		_ resource: R,
//		_ result: Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>,
//		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
//	) where R: Resource {
//		switch result {
//		case .success(let model):
//			completion(.success(model))
//		case .failure(let error):
//			// For any failures we check if the resource has some value defined for the retryingCount and also has some retries left. If so, we call load() recursivly.
//			if let retryingCount = resource.retryingCount,
//			   retryingCount > 0 {
//				Log.debug("Retry for resource discovered. Retry counter at: \(retryingCount)", log: .client)
//				var mutatableResource = resource
//				mutatableResource.retryingCount? -= 1
//				Log.debug("Remaining retries now: \(mutatableResource.retryingCount ?? 0)", log: .client)
//				load(mutatableResource, completion)
//			} else {
//				// Now after all retries exhausted (or we did not had any retry), we check if we can return a default value or not.
//				completion(failureOrDefaultValueHandling(resource, error))
//			}
//		}
//	}
}
