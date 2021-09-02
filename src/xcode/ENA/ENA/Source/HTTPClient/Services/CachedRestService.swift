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
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
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
						completion(.success(model))
					case .failure:
						completion(.failure(.decodeError))
					}
				} else {
					completion(.failure(.cacheError))
				}
				// return the model from the cache - at the moment this nil only
			case let .success(model):
				guard let model = model else {
					completion(.failure(.serverError(nil)))
					return
				}
				let serverDate = response?.dateHeader ?? Date()
				let cachedModel = CacheData(data: modelData, eTag: eTag, date: serverDate)
				self?.cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
				completion(.success(model))
			case let .failure(error):
				completion(.failure(error))
			}
		}
	}

	func didDecodeModelSuccessfully<T>(resource: T, bodyData: Data?, response: HTTPURLResponse) where T: Resource {
		guard let eTag = response.value(forCaseInsensitiveHeaderField: "ETag") else {
			Log.debug("no eTag found - stop cache logic here")
			return
		}
//		let responseDate = response.dateHeader ?? Date()
//		return CacheData(data: bodyData, eTag: eTag, date: responseDate)
	}


	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let session: URLSession
	private let environment: EnvironmentProviding
	private let wrappedService: Service

	private let cache: NSCache<NSNumber, CacheData> = NSCache()

}

