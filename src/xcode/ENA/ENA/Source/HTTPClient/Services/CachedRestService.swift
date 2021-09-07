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
			guard let self = self,
				error == nil,
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
				case .failure:
					completion(.failure(.decodeError))
				}

			case 201...204:
				completion(.success(nil))

			case 304:
				switch self.cached(resource: resource) {
				case .success(let model):
					completion(.success(model))
				case .failure:
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

	private func decodeModel<T>(resource: T, _ bodyData: Data?, _ response: HTTPURLResponse? = nil) -> Result<T.Model, ResourceError> where T: Resource {
		switch resource.decode(bodyData) {
		case .success(let model):
			guard let eTag = response?.value(forCaseInsensitiveHeaderField: "ETag"),
				  let data = bodyData else {
				Log.debug("ETag not found - do not write to cache")
				return .success(model)
			}
			let serverDate = response?.dateHeader ?? Date()
			let cachedModel = CacheData(data: data, eTag: eTag, date: serverDate)
			cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
			return .success(model)

		case .failure:
			return .failure(.decoding)
		}
	}

	private func cached<T>(resource: T) -> Result<T.Model, ResourceError> where T: Resource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) else {
			Log.debug("no data found in cache", log: .client)
			return .failure(.missingData)
		}
		return decodeModel(resource: resource, cachedModel.data)
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
