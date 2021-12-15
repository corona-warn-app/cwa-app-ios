//
// 🦠 Corona-Warn-App
//

import Foundation

/**
A Service has to define:
- what should happen when trying to load a resource from an endpoint (load<S, R>).
- how to construct a urlRequest in dependency of the informations given in the locator and the parameters of the sendResource and receiveResource (urlRequest<S, R>)
- how a generic ReceiveResource has to e decoded (decodeModel<R>)
- how a generic ReceiveResource has to be cached or even not cached cached<R>
- if in dependency of the specific Service, some customHeaders (e.g. ETag) has to be added to the http request headers (customHeaders<R>).
*/

protocol Service {

	init(
		environment: EnvironmentProviding,
		session: URLSession?
	)

	var session: URLSession { get }
	var environment: EnvironmentProviding { get }
	
	/// loads a ReceiveModel from an external endpoint via http call.
	///
	/// - Parameters:
	///   - locator: The locator of the load call. The locator contains the url, the endpoint and other describing things to build the URLRequest.
	///   - sendResource: Generic ("S") object of type SendResource. This is afaik the object to be send in the body of the http request.
	///   - receiveResource: Generic ("R") object of type ReceiveResource. This is afaik the object to be received in the body of the http response.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call and is defined in the receiveResource parameter. Can be for example a protobuf or JSON object. If the load calls fails, the result has a ServiceError, which can contains a ResourceError.
	func load<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource
	/// creates the url for the http call.
	///
	/// - Parameters:
	///   - locator: The locator of the load call. The locator contains the url, the endpoint and other describing things to build the URLRequest.
	///   - sendResource: Generic ("S") object of type SendResource. This is afaik the object to be send in the body of the http request.
	///   - receiveResource: Generic ("R") object of type ReceiveResource. This is afaik the object to be received in the body of the http response.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call and is defined in the receiveResource parameter. Can be for example a protobuf or JSON object. If the load calls fails, the result has a ServiceError, which can contains a ResourceError.
	func urlRequest<S, R>(
		_ locator: Locator,
		_ sendResource: S,
		_ receiveResource: R
	) -> Result<URLRequest, ResourceError> where S: SendResource, R: ReceiveResource
	
	/// decodes the data from the http response.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - locator: The locator of the load call. The locator contains the url, the endpoint and other describing things to build the URLRequest.
	///   - bodyData: The data of the http response's body
	///   - response: The HTTPURLResponse of the http response
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call. Can be for example a protobuf or JSON object. If the load calls fails, the result has a ServiceError, which can contains a ResourceError.
	func decodeModel<R>(
		_ resource: R,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource

	/// implement this functions if you want to cache a resource.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - locator: The locator of the load call. The locator contains the url, the endpoint and other describing things to build the URLRequest.
	///   - completion: Swift-Result of loading. If successful, it contains the concrete object of our call. Can be for example a protobuf or JSON object. If the load calls fails, the result has a ServiceError, which can contains a ResourceError.
	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource
	
	
	/// implement this functions if you want to check if we have something cached for this resource.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - return: True if we have a cached model of this resource, otherwise false.
	func hasCachedData<R>(
		_ resource: R
	) -> Bool where R: Resource
	
	/// implement this functions if you want to set special headers.
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - locator: The locator of the load call. The locator contains the url, the endpoint and other describing things to build the URLRequest.
	///   - return: Returns nil or the header fields as dictionary. Example here are the ETag or applicationType- header fields.
	func customHeaders<R>(
		_ receiveResource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource

	/// override to indicate for given status codes a special use case cache handling will be done
	///
	/// - Parameters:
	///   - resource: Generic ("R") object and normally of type ReceiveResource.
	///   - statusCode: the status code of the URLResponse
	///   - return: true if no special cache use case handling exists for the given status code
	func hasNoStatusCodeCacheUseCase<R>(
		_ resource: R,
		_ statusCode: Int
	) -> Bool where R: Resource

}

extension Service {
	
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
}
