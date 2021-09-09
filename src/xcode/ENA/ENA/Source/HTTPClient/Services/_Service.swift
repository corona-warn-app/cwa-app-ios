//
// 🦠 Corona-Warn-App
//

import Foundation

enum ServiceError: Error, Equatable {
	case serverError(Error?)
	case unexpectedResponse(Int)
	case resourceError(ResourceError?)

	// MARK: - Protocol Equatable

	static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
		switch (lhs, rhs) {

		case let (.serverError(lError), .serverError(rError)):
			return lError?.localizedDescription == rError?.localizedDescription
		case (.serverError, _):
			return false

		case let (.unexpectedResponse(lInt), .unexpectedResponse(rInt)):
			return lInt == rInt
		case (.unexpectedResponse, _):
			return false

		case let (.resourceError(lResourceError), .resourceError(rResourceError)):
			return lResourceError == rResourceError
		case (.resourceError, _):
			return false
		}
	}
}

protocol Service: RestServiceProviding {

	init(environment: EnvironmentProviding)

	var session: URLSession { get }
	var environment: EnvironmentProviding { get }

	func decodeModel<T>(
		_ resource: T,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource

	func cached<T>(
		_ resource: T,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource

	func customHeaders<T>(for resource: T) -> [String: String]? where T: ResponseResource
}

extension Service {

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		switch resource.urlRequest(
			environmentData: environment.currentEnvironment(),
			customHeader: customHeaders(for: resource)
		) {
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
					decodeModel(resource, bodyData, response, completion)

				case 202...204:
					completion(.success(nil))

				case 304:
					cached(resource, completion)

				default:
					completion(.failure(.unexpectedResponse(response.statusCode)))
				}
			}.resume()
		}
	}

	func load<S, R>(
		locationResource: LocationResource,
		sendResource: S?,
		receiveResource: R,
		completion: @escaping () -> Void
	) where S: SendResource, R: ReceiveResource {
		// add default loading here
	}

	func decodeModel<T>(
		_ resource: T,
		_ bodyData: Data? = nil,
		_ response: HTTPURLResponse? = nil,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		switch resource.decode(bodyData) {
		case .success(let model):
			completion(.success(model))
		case .failure(let resourceError):
			completion(.failure(.resourceError(resourceError)))
		}
	}

	func cached<T>(
		_ resource: T,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		completion(.failure(.resourceError(.notModified)))
	}

	func customHeaders<T>(for resource: T) -> [String: String]? where T: ResponseResource {
		return nil
	}

}
