//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Specific implementation of a service who is doing nothing special, so it is the default one.
It uses the coronaWarnSessionConfiguration.
Because it does nothing special and in the ServiceHook a implementation is done already, the code is small. Must be implemented for the RestServiceProviding switch.
*/
class StandardRestService: Service {

	// MARK: - Init

	required init(
		environment: EnvironmentProviding = Environments(),
		session: URLSession? = nil
	) {
		self.environment = environment
		self.optionalSession = session
	}

	// MARK: - Protocol Service

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		optionalSession ??
		.coronaWarnSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegateQueue: .main
		)
	}()

	// MARK: - Private

	private let optionalSession: URLSession?

}
