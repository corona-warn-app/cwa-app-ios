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
		environment: EnvironmentProviding = Environments()
	) {
		self.environment = environment
	}

	// MARK: - Protocol Service

	let environment: EnvironmentProviding

	lazy var session: URLSession = {
		.coronaWarnSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegateQueue: .main
		)
	}()

}
