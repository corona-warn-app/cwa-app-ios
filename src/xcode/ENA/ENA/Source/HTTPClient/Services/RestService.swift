//
// 🦠 Corona-Warn-App
//

import Foundation

/// this service can communicate with a rest server
///
class RestService: Service {

	// MARK: - Init

	init(
		defaultSession: URLSession = URLSession(configuration: .coronaWarnSessionConfiguration()),
		cachedSession: URLSession = URLSession(configuration: .cachingSessionConfiguration()),
		environment: EnvironmentProviding = Environments()
	) {
		self.defaultSession = defaultSession
		self.cachedSession = cachedSession
		self.environment = environment
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource {

		var resource = resource
		if resource.cachingMode == .always,
		   let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) {
			resource.addHeaders(customHeaders: ["If-None-Match": cachedModel.eTag])
		}

		let request = resource.locator.urlRequest(environmentData: environment.currentEnvironment())
		let session = resource.cachingMode == .always ? cachedSession : defaultSession
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
					switch resource.cachingMode {
					case .none:
						completion(.success(model))
					case .always:
						guard let eTag = response.value(forCaseInsensitiveHeaderField: "ETag"),
							  let data = bodyData else {
							completion(.success(model))
							Log.debug("ETag not found - cache problem")
							return
						}
						let serverDate = response.dateHeader ?? Date()
						let cachedModel = CacheData(data: data, eTag: eTag, date: serverDate)
						self?.cache.setObject(cachedModel, forKey: NSNumber(value: resource.locator.hashValue))
					}
				case .failure:
					completion(.failure(.decodeError))
				}
			case 201...204:
				completion(.success(nil))

			case 304:
				switch resource.cachingMode {
				case .none:
					completion(.failure(.notModified))
				case .always:
					if let cachedModel = self?.cache.object(forKey: NSNumber(value: resource.locator.hashValue)) {
						switch resource.decode(cachedModel.data) {
						case .success(let model):
							completion(.success(model))
						case .failure:
							completion(.failure(.decodeError))
						}
					}
				}

			default:
				completion(.failure(.unexpectedResponse(response.statusCode)))
			}
		}.resume()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let defaultSession: URLSession
	private let cachedSession: URLSession
	private let environment: EnvironmentProviding
	// dummy cache for the moment
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
