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

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly())
	}()

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
