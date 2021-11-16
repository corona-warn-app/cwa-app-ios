//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Specific implementation of a service who is only sending and receiving when using wifi.
It uses the coronaWarnSessionConfigurationWifiOnly.
*/
class WifiOnlyRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
	}

	// MARK: - Overrides

	// MARK: - Protocol Service

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		optionalSession ??
		.coronaWarnSession(
			configuration: .coronaWarnSessionConfigurationWifiOnly()
		)
	}()

	// MARK: - Private

	private let optionalSession: URLSession?

}
