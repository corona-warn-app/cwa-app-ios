//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Specific implementation of a service who is doing the caching stuff (http status code 304 handling).
It uses the cachingSessionConfiguration.
For http requests, it adds the ETag header field.
For http responses, when receiving a http status code 304 it checks if the ReceiveResource was already cached before and if so, it returns the cached one. It also caches the ReceiveResource when receiving.
*/
class CachedRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
	}

	// MARK: - Protocol Service

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		.coronaWarnSession(
			configuration: .cachingSessionConfiguration()
		)
	}()

	func decodeModel<R>(
		_ resource: R,
		_ bodyData: Data?,
		_ response: HTTPURLResponse?,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.receiveResource.decode(bodyData) {
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

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: resource.locator.hashValue)) else {
			Log.debug("no data found in cache", log: .client)
			completion(.failure(.resourceError(.missingData)))
			return
		}
		decodeModel(resource, cachedModel.data, nil, completion)
	}

	func customHeaders<R>(
		_ receiveResource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource {
		guard let cachedModel = cache.object(forKey: NSNumber(value: locator.hashValue)) else {
			Log.debug("ResponseResource not found in cache", log: .client)
			return nil
		}
		return ["If-None-Match": cachedModel.eTag]
	}

	// MARK: - Private

	private let optionalSession: URLSession?

	/// at the moment we use a simple NSCache
	private let cache: NSCache<NSNumber, CacheData> = NSCache<NSNumber, CacheData>()
}


/// helper class for the NSCache

fileprivate class CacheData: NSObject {

	init(data: Data, eTag: String, date: Date) {
		self.data = data
		self.eTag = eTag
		self.date = date
	}

	let data: Data
	let eTag: String
	let date: Date
}
