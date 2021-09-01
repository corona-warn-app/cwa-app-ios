//
// 🦠 Corona-Warn-App
//

import Foundation

class WifiOnlyRestService: Service {

	// MARK: - Init

	init(
		session: URLSession = URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly()),
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
		wrappedService.load(resource: mutableResource, completion: completion)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let session: URLSession
	private let environment: EnvironmentProviding
	private let wrappedService: Service

	private var eTagDummy: String? = "Hallo eTag"

}
