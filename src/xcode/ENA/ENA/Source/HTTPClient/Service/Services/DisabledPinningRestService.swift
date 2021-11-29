//
// 🦠 Corona-Warn-App
//

import Foundation

/**
Specific implementation of a service who is doing nothing special, but disables the certificate pinning.
It uses the coronaWarnSessionConfiguration.
*/
class DisabledPinningRestService: Service {

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
			delegateQueue: .main,
			withPinning: false
		)
	}()

	// MARK: - Private

	private let optionalSession: URLSession?

}
