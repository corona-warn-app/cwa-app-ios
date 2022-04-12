//
// 🦠 Corona-Warn-App
//

import ENASecurity

public enum TrustEvaluationError: Error {
	case `default` (DefaultTrustEvaluationError)
	case jsonWebKey (JSONWebKeyTrustEvaluationError)
	case allowList (JSONWebKeyTrustEvaluationError)
	case notSupportedAuthenticationMethod
	case invalidSecTrust
}

protocol TrustEvaluating {
	func evaluate(
		challenge: URLAuthenticationChallenge,
		trust: SecTrust,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	)

	var trustEvaluationError: TrustEvaluationError? { get set }
}
