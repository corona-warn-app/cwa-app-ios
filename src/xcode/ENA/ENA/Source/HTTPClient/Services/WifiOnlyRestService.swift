//
// 🦠 Corona-Warn-App
//

import Foundation

class WifiOnlyRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments()
	) {
		self.environment = environment
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	func load<T>(
		resource: T,
		completion: @escaping (Result<T.Model?, ServiceError>) -> Void
	) where T: Resource {
//		wrappedService.load(resource: resource, completion: completion)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private lazy var session: URLSession = {
		URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly())
	}()

	private let environment: EnvironmentProviding

}
