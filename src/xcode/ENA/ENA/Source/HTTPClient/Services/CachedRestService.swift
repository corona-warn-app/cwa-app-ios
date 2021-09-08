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

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		URLSession(configuration: .cachingSessionConfiguration())
	}()


	func decodeModel<T>(
		_ resource: T,
		_ bodyData: Data? = nil,
		_ response: HTTPURLResponse? = nil,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		switch resource.decode(bodyData) {
		case .success(let model):
			guard let eTag = response?.value(forCaseInsensitiveHeaderField: "ETag"),
				  let data = bodyData else {
				Log.debug("ETag not found - do not write to cache")
				 completion(.success(model))
				return
			}
			let serverDate = response?.dateHeader ?? Date()
			let cachedModel = CacheData(data: data, eTag: eTag, date: serverDate)
			cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
			completion(.success(model))

		case .failure:
			completion(.failure(.resourceError(.decoding)))
		}
	}

	func cached<T>(
		_ resource: T,
		_ completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: ResponseResource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) else {
			Log.debug("no data found in cache", log: .client)
			completion(.failure(.resourceError(.missingData)))
			return
		}
		decodeModel(resource, cachedModel.data, nil, completion)
	}

	func customHeaders<T>(for resource: T) -> [String: String]? where T: ResponseResource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) else {
			Log.debug("ResponseResource not found in cache", log: .client)
			return nil
		}
		return ["If-None-Match": cachedModel.eTag]
	}

	// MARK: - Public

	// MARK: - Internal
	
	// MARK: - Private

	// dummy cache for the moment
	private let cache: NSCache<NSNumber, CacheData> = NSCache<NSNumber, CacheData>()
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
