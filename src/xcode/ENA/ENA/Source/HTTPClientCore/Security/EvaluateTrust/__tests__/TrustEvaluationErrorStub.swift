//
// 🦠 Corona-Warn-App
//

import Foundation

struct TrustEvaluationErrorStub: TrustEvaluating {

	init(error: Error) {
		trustEvaluationError = error
	}
	
	// MARK: - Protocol TrustEvaluating
	
	// We don't need to implement, trustEvaluationError will be used by the delegate to read the error.
	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {}
	
	var trustEvaluationError: Error?
}
