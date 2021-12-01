//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

class DynamicEvaluateTrust: EvaluateTrust {

	// MARK: - Init

	init(
		jwkSet: [JSONWebKey],
		trustEvaluation: TrustEvaluation
	) {
		self.jwkSet = jwkSet
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol EvaluateTrust

	func evaluate(
		challenge: URLAuthenticationChallenge,
		trust: SecTrust,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
#if DEBUG
		// debug/review: print the chain
		for i in 0..<SecTrustGetCertificateCount(trust) {
			if let cert = SecTrustGetCertificateAtIndex(trust, i) {
				Log.debug("[\(challenge.protectionSpace.host)] @ \(i): \(cert)", log: .crypto)
			}
		}
#endif
		let result = trustEvaluation.check(
			trust: trust,
			against: jwkSet,
			logMessage: { message in
				Log.debug("Log message from trust evaluation check: \(message)", log: .client)
			}
		)
		switch result {
		case .success:
			completionHandler(.useCredential, URLCredential(trust: trust))
		case .failure(let error):
			Log.debug("AuthenticationChallenge failed with error \(error.localizedDescription)", log: .client)
			trustEvaluationError = error
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
	
	// MARK: - Internal

	var trustEvaluationError: Error?

	// MARK: - Private

	private let trustEvaluation: TrustEvaluation
	private var jwkSet: [JSONWebKey]

}
