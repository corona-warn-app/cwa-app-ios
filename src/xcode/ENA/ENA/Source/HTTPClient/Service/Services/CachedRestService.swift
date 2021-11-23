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
		fatalError("CachedRestService cannot be used without a cache. Please use the other init and provide a cache.")
	}

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil,
		cache: KeyValueCaching
	) {
		self.environment = environment
		self.optionalSession = session
		self.cache = cache
	}

	// MARK: - Protocol Service

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		optionalSession ??
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
			cache[resource.locator.hashValue] = cachedModel
			completion(.success(model))

		case .failure:
			completion(.failure(customError(in: resource, for: .resourceError(.decoding))))
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let cachedModel = cache[resource.locator.hashValue] else {
			Log.debug("no data found in cache", log: .client)
			completion(.failure(customError(in: resource, for: .resourceError(.missingData))))
			return
		}
		decodeModel(resource, cachedModel.data, nil, completion)
	}

	func customHeaders<R>(
		_ receiveResource: R,
		_ locator: Locator
	) -> [String: String]? where R: ReceiveResource {
		guard let cachedModel = cache[locator.hashValue] else {
			Log.debug("ResponseResource not found in cache", log: .client)
			return nil
		}
		return ["If-None-Match": cachedModel.eTag]
	}

	// MARK: - Private

	private let optionalSession: URLSession?
	private var cache: KeyValueCaching
}
