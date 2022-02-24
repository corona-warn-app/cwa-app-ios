//
// 🦠 Corona-Warn-App
//

struct DisabledTrustEvaluation: TrustEvaluating {

	init() {}

	// MARK: - Protocol TrustEvaluating

	/// Common evaluation, covering iOS versions 12.5 or 13.x
	/// - Parameters:
	///   - challenge: A challenge from a server requiring authentication from the client.
	///   - trust: Shortcut for `challenge.protectionSpace.serverTrust`
	///   - completionHandler: the completion handler to accept or reject the request
	func evaluate(
		challenge: URLAuthenticationChallenge,
		trust: SecTrust,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		// Because we ignore certificate pinnning, we return always a success
		completionHandler(.useCredential, URLCredential(trust: trust))
	}

	// MARK: - Internal

	var trustEvaluationError: TrustEvaluationError?


}
