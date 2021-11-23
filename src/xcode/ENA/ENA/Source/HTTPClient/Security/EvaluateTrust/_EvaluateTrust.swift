//
// 🦠 Corona-Warn-App
//

protocol EvaluateTrust {
	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}
