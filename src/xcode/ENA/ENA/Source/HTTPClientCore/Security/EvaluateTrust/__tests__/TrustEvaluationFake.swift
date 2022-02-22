//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class TrustEvaluationFake: TrustEvaluating {
	func evaluate(
		challenge: URLAuthenticationChallenge,
		trust: SecTrust,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		completionHandler(.useCredential, URLCredential(trust: trust))
	}
	
	var trustEvaluationError: Error?
}

extension TrustEvaluating where Self == TrustEvaluationFake {
	static func fake() -> TrustEvaluationFake {
		return TrustEvaluationFake()
	}
}
