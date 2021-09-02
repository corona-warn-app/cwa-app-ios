//
// 🦠 Corona-Warn-App
//

import Foundation

class DefaultRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.environment = environment
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource {
		let request = resource.locator.urlRequest(environmentData: environment.currentEnvironment())
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
				switch resource.decode(bodyData) {
				case .success(let model):
					completion(.success(model))
				case .failure:
					completion(.failure(.decodeError))
				}
			case 201...204:
				completion(.success(nil))

			case 304:
				completion(.failure(.notModified))

			// handle error / notModified cases here

			default:
				completion(.failure(.unexpectedResponse(response.statusCode)))
			}
		}.resume()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private lazy var session: URLSession = {
		URLSession(configuration: .coronaWarnSessionConfiguration())
	}()

	private let environment: EnvironmentProviding
}
