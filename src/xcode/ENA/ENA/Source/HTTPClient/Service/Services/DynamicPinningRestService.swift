//
// 🦠 Corona-Warn-App
//

import Foundation

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
		if let session = optionalSession {
			return session
		}

		let newSessionDelegate = CoronaWarnURLSessionDelegate(jwkSet: jwkSet)
		let session = URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: newSessionDelegate,
			delegateQueue: .main
		)
		self.urlSessionDelegate = newSessionDelegate
		return session
	}()

	// MARK: - Private

	private let optionalSession: URLSession?
	private let jwkSet: [Data]

	// MARK: - Internal

	weak var urlSessionDelegate: CoronaWarnURLSessionDelegate?

}
