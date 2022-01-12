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
		_ headers: [AnyHashable: Any],
		_ isCachedData: Bool,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		switch resource.receiveResource.decode(bodyData, headers: headers) {
		case .success(let model):
			guard let eTag = headers.value(caseInsensitiveKey: "ETag"),
				  let data = bodyData else {
					  Log.error("Neither eTag nor some data found. Abort with missing eTag error.", log: .client)
					  completion(.failure(customError(in: resource, for: .resourceError(.missingEtag))))
					  return
				  }
			
			// Update cache only if we fetched some fresh data.
			if !isCachedData {
				let serverDate = headers.dateHeader ?? Date()
				let cachedModel = CacheData(data: data, eTag: eTag, date: serverDate)
				cache[resource.locator.hashValue] = cachedModel
				Log.info("Fetched new cached data and wrote them to the cache", log: .client)
			}
			
			completion(.success(model))
			
		case .failure:
			Log.error("Decoding for receive resource failed.", log: .client)
			failureOrDefaultValueHandling(resource, .resourceError(.decoding), completion)
		}
	}

	func cached<R>(
		_ resource: R,
		_ completion: @escaping (Result<R.Receive.ReceiveModel, ServiceError<R.CustomError>>) -> Void
	) where R: Resource {
		guard let cachedModel = cache[resource.locator.hashValue] else {
			Log.error("No data found in cache", log: .client)
			failureOrDefaultValueHandling(resource, .resourceError(.missingData), completion)
			return
		}
		decodeModel(resource, cachedModel.data, ["ETag": cachedModel.eTag], true, completion)
	}
	
	func hasCachedData<R>(
		_ resource: R
	) -> Bool where R: Resource {
		return cache[resource.locator.hashValue] != nil
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

	func hasStatusCodeCachePolicy<R>(
		_ resource: R,
		_ statusCode: Int
	) -> Bool where R: Resource {
		// Check if Resource.type has a cache policies and if policy .statusCode is included
		guard case let .caching(cachePolicies) = resource.type,
			  cachePolicies.contains(CacheUsePolicy.statusCode(statusCode)) else {
			return false
		}
		// Fail because you should not override status codes 200, 201 and 204 with this cache policy.
		// The codes here are mapped from the status code handling in _Service+Default. This must always be synced.
		if statusCode == 200 || statusCode == 201 || statusCode == 204 {
			fatalError("You should not override status code 200, 201 and 204 with a cache policy.")
		}
		return true
	}

	// MARK: - Private

	private let optionalSession: URLSession?
	private var cache: KeyValueCaching
}
