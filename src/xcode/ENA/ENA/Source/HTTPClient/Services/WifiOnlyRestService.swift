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
		completion: @escaping (Result<(T.Model?, HTTPURLResponse?), ServiceError>) -> Void
	) where T: Resource {
		wrappedService.load(resource: resource, completion: completion)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let session: URLSession
	private let environment: EnvironmentProviding
	private let wrappedService: Service

}
