//
// 🦠 Corona-Warn-App
//

import Foundation

class CachedRestService: Service {

	// MARK: - Init

	init(
		session: URLSession = URLSession(configuration: .cachingSessionConfiguration()),
		environment: EnvironmentProviding = Environments(),
		wrappedService: Service? = nil
	) {
		self.session = session
		self.environment = environment
		self.wrappedService = wrappedService ?? RestService(session: session, environment: environment)
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	func load<T>(
		resource: T,
		completion: @escaping (Result<(T.Model?, HTTPURLResponse?), ServiceError>) -> Void
	) where T: Resource {
		// ToDo - lookup an eTag in the cache for requested resource
		// use the dummy at the moment only
		var mutableResource = resource
		if let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) {
			mutableResource.addHeaders(customHeaders: ["If-None-Match": cachedModel.eTag])
		}
		wrappedService.load(resource: mutableResource) { [weak self] result in
			switch result {
			case let .failure(notModifiedError) where notModifiedError == .notModified:
				if let cachedModel = self?.cache.object(forKey: NSNumber(value: resource.locator.hashValue)) {
					switch resource.decode(cachedModel.data) {
					case .success(let model):
						completion(.success((model, nil)))
					case .failure:
						completion(.failure(.decodeError))
					}
				} else {
					completion(.failure(.cacheError))
				}
				// return the model from the cache - at the moment this nil only
			case let .success((model, response)):
				guard
					let model = model,
					let modelData = resource.data(from: model),
					let eTag = response?.value(forCaseInsensitiveHeaderField: "ETag")
				else {
					completion(.failure(.serverError(nil)))
					return
				}
				let serverDate = response?.dateHeader ?? Date()
				let cachedModel = CacheData(data: modelData, eTag: eTag, date: serverDate)
				self?.cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
				completion(.success((model, response)))
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let session: URLSession
	private let environment: EnvironmentProviding
	private let wrappedService: Service

	private let cache: NSCache<NSNumber, CacheData> = NSCache()

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
