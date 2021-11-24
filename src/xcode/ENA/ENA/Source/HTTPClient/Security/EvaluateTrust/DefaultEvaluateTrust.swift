//
// 🦠 Corona-Warn-App
//

struct DefaultEvaluateTrust: EvaluateTrust {
	
	init(
		publicKeyHash: String
	) {
		self.publicKeyHash = publicKeyHash
	}
	
	// MARK: - Protocol EvaluateTrust
	
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
#if DEBUG
		// debug/review: print the chain
		for i in 0..<SecTrustGetCertificateCount(trust) {
			if let cert = SecTrustGetCertificateAtIndex(trust, i) {
				Log.debug("[\(challenge.protectionSpace.host)] @ \(i): \(cert)", log: .crypto)
			}
		}
#endif
		
		// we expect a chain of at least 2 certificates
		// index '1' is the required intermediate
		guard let serverCertificate = SecTrustGetCertificateAtIndex(trust, 1),
			  let serverPublicKey = SecCertificateCopyKey(serverCertificate),
			  let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ) as Data?,
			  publicKeyHash == serverPublicKeyData.sha256String()
		else {
			completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			return
		}
		
		// Success! This is our server
		completionHandler(.useCredential, URLCredential(trust: trust))
	}
	
	// MARK: - Internal

	var trustEvaluationError: Error?

	// MARK: - Private
	
	private let publicKeyHash: String
	
}
