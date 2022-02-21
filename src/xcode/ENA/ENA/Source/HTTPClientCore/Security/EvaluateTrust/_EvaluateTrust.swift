//
// 🦠 Corona-Warn-App
//

protocol TrustEvaluating {
	func evaluate(
		challenge: URLAuthenticationChallenge,
		trust: SecTrust,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	)

	var trustEvaluationError: Error? { get set }
}
