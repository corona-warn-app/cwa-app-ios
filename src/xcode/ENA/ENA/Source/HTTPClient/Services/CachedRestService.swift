//
// 🦠 Corona-Warn-App
//

import Foundation

class CachedRestService: Service {

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
		let request = resource.locator.urlRequest(
			environmentData: environment.currentEnvironment(),
			eTag: eTag(for: resource)
		)
		session.dataTask(with: request) { [weak self] bodyData, response, error in
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
					guard let eTag = response.value(forCaseInsensitiveHeaderField: "ETag"),
						  let data = bodyData else {
						completion(.success(model))
						Log.debug("ETag not found - cache problem")
						return
					}
					let serverDate = response.dateHeader ?? Date()
					let cachedModel = CacheData(data: data, eTag: eTag, date: serverDate)
					self?.cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
					completion(.success(model))
				case .failure:
					completion(.failure(.decodeError))
				}
			case 201...204:
				completion(.success(nil))

			case 304:
				if let cachedModel = self?.cache.object(forKey: NSNumber(value: resource.locator.hashValue)) {
					switch resource.decode(cachedModel.data) {
					case .success(let model):
						completion(.success(model))
					case .failure:
						completion(.failure(.decodeError))
					}
				} else {
					completion(.failure(.cacheError))
				}

			default:
				completion(.failure(.unexpectedResponse(response.statusCode)))
			}
		}.resume()
	}

	// MARK: - Public

	// MARK: - Internal
	
	// MARK: - Private

	private lazy var session: URLSession = {
		URLSession(configuration: .cachingSessionConfiguration())
	}()

	private let environment: EnvironmentProviding
	// dummy cache for the moment
	private let cache: NSCache<NSNumber, CacheData> = NSCache<NSNumber, CacheData>()

	func eTag<T>(for resource: T) -> String? where T: Resource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) else {
			Log.debug("Resource not found in cache", log: .client)
			return nil
		}
		return cachedModel.eTag
	}

}

class CacheData: NSObject {

	init(data: Data, eTag: String, date: Date) {
		self.data = data
		self.eTag = eTag
		self.date = date
	}

	let data: Data
	let eTag: String
	let date: Date
}
