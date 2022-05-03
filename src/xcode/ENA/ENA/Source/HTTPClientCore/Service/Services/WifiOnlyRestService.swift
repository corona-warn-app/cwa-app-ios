//
// 🦠 Corona-Warn-App
//

/**
Specific implementation of a service who is only sending and receiving when using wifi.
It uses the coronaWarnSessionConfigurationWifiOnly.
*/
class WifiOnlyRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments(),
		optionalSession: URLSession? = nil
	) {
		self.environment = environment
		self.session = Self.makeSession(wifiOnly: true, optionalSession: optionalSession)
	}

	// MARK: - Protocol Service

	let environment: EnvironmentProviding
	private(set) var session: URLSession

	// MARK: - Private

	private static func makeSession(wifiOnly: Bool, optionalSession: URLSession?) -> URLSession {
		if let optionalSession = optionalSession {
			return optionalSession
		}
		let configuration: URLSessionConfiguration = wifiOnly ?
			.coronaWarnSessionConfigurationWifiOnly() :
			.coronaWarnSessionConfiguration()

		return URLSession(configuration: configuration)
	}

#if !RELEASE
	var isWifiOnlyActive: Bool {
		let wifiOnlyConfiguration = URLSessionConfiguration.coronaWarnSessionConfigurationWifiOnly()
		if #available(iOS 13.0, *) {
			return session.configuration.allowsCellularAccess == wifiOnlyConfiguration.allowsCellularAccess &&
				session.configuration.allowsExpensiveNetworkAccess == wifiOnlyConfiguration.allowsExpensiveNetworkAccess &&
				session.configuration.allowsConstrainedNetworkAccess == wifiOnlyConfiguration.allowsConstrainedNetworkAccess
		} else {
			return session.configuration.allowsCellularAccess == wifiOnlyConfiguration.allowsCellularAccess
		}
	}

	func updateSession(wifiOnly: Bool) {
		session.invalidateAndCancel()
		session = Self.makeSession(wifiOnly: wifiOnly, optionalSession: nil)
	}
#endif
}
