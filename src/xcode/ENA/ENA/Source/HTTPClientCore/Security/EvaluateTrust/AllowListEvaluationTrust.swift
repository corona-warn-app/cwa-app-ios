//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

class AllowListEvaluationTrust: TrustEvaluating {

	// MARK: - Init

	init(
		allowList: [ValidationServiceAllowlistEntry],
		trustEvaluation: ENASecurity.JSONWebKeyTrustEvaluation
	) {
		self.allowList = allowList
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Protocol TrustEvaluating

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
		for item in allowList {
			Log.debug("\(item)", log: .ticketValidationAllowList)
		}
#endif
		let result = trustEvaluation.checkServerCertificateAgainstAllowlist(
			hostname: challenge.protectionSpace.host,
			trust: trust,
			allowList: allowList
		)
		switch result {
		case .success:
			completionHandler(.useCredential, URLCredential(trust: trust))
		case .failure(let error):
			Log.debug("AuthenticationChallenge failed with error \(error.localizedDescription)", log: .client)
			trustEvaluationError = .jsonWebKey(error)
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}
		
	// MARK: - Internal

	var trustEvaluationError: TrustEvaluationError?

	// MARK: - Private

	private let trustEvaluation: ENASecurity.JSONWebKeyTrustEvaluation
	private var allowList: [ValidationServiceAllowlistEntry]

}
