//
// 🦠 Corona-Warn-App
//

class DynamicPinningRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
		self.jwkSet = []
	}

	init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil,
		jwkSet: [Data]
	) {
		self.environment = environment
		self.optionalSession = session
		self.jwkSet = jwkSet
	}

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
	private let jwkSet: [Data]
}
