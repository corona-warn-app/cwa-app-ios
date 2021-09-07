//
// 🦠 Corona-Warn-App
//

import Foundation

enum ServiceError: Error, Equatable {
	case serverError(Error?)
	case unexpectedResponse(Int)
	case resourceError(ResourceError)

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
		resource: T,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?
	) -> Result<T.Model, ResourceError> where T: Resource

	func cached<T>(
		resource: T
	) -> Result<T.Model, ResourceError> where T: Resource

	func customHeaders<T>(for resource: T) -> [String: String]? where T: Resource
}

extension Service {

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource {
		let request = resource.urlRequest(
			environmentData: environment.currentEnvironment(),
			customHeader: customHeaders(for: resource)
		)
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
			case 200:
				switch self.decodeModel(resource: resource, bodyData, response) {
				case .success(let model):
					completion(.success(model))
				case .failure(let resourceError):
					completion(.failure(.resourceError(resourceError)))
				}

			case 201...204:
				completion(.success(nil))

			case 304:
				switch self.cached(resource: resource) {
				case .success(let model):
					completion(.success(model))
				case .failure(let resourceError):
					completion(.failure(.resourceError(resourceError)))
				}

			default:
				completion(.failure(.unexpectedResponse(response.statusCode)))
			}
		}.resume()
	}

	func decodeModel<T>(
		resource: T,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?
	) -> Result<T.Model, ResourceError> where T: Resource {
		return resource.decode(bodyData)
	}

	func cached<T>(
		resource: T
	) -> Result<T.Model, ResourceError> where T: Resource {
		return .failure(.notModified)
	}

	func customHeaders<T>(for resource: T) -> [String: String]? where T: Resource {
		return nil
	}

}
