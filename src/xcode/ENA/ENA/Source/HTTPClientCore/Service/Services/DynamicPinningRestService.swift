//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

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
		jwkSet: [JSONWebKey]
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

		let session = URLSession(
			configuration: .coronaWarnSessionConfiguration(),
			delegate: CoronaWarnURLSessionDelegate(jwkSet: jwkSet),
			delegateQueue: .main
		)
		return session
	}()

	// MARK: - Private

	private let optionalSession: URLSession?
	private let jwkSet: [JSONWebKey]

	// MARK: - Internal

	var urlSessionDelegate: URLSessionDelegate? {
		session.delegate as? CoronaWarnURLSessionDelegate
	}

}
