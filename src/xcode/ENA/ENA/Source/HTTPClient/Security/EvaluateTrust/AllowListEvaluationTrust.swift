//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

class AllowListEvaluationTrust: EvaluateTrust {

	// MARK: - Init

	init(
		allowList: [ValidationServiceAllowlistEntry],
		trustEvaluation: TrustEvaluation,
		store: Store
	) {
		self.allowList = allowList
		self.trustEvaluation = trustEvaluation
		self.store = store
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
		for item in allowList {
			Log.debug("\(item)", log: .ticketValidationAllowList)
		}
	#endif
		var result = trustEvaluation.checkServerCertificateAgainstAllowlist(
			hostname: challenge.protectionSpace.host,
			trust: trust,
			allowList: allowList
		)

	#if !RELEASE
		// override result if skipAllowlistValidation is true
		result = store.skipAllowlistValidation ? .success(()) : result
	#endif

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
	private let store: Store

	private var allowList: [ValidationServiceAllowlistEntry]

}
