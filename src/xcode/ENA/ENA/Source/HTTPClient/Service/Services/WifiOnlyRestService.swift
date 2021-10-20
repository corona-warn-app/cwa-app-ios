//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Specific implementation of a service who is only sending and receiving when using wifi.
It uses the coronaWarnSessionConfigurationWifiOnly.
// TODO check: Is everything done here?
*/
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
		.coronaWarnSession(
			configuration: .coronaWarnSessionConfigurationWifiOnly()
		)
	}()

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

}
