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
		if let eTag = eTagDummy {
			mutableResource.addHeaders(customHeaders: ["If-None-Match": eTag])
		}
		wrappedService.load(resource: mutableResource) { result in
			switch result {
			case let .failure(notModifiedError) where notModifiedError == .notModified:
				// return the model from the cache - at the moment this nil only
				completion(.success(nil))
			case let .success(model):
				completion(.success(model))
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

	private var eTagDummy: String? = "Hallo eTag"

}
