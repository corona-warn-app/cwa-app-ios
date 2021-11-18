//
// 🦠 Corona-Warn-App
//

import Foundation

protocol EvaluateTrust {
	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

struct DefaultEvaluateTrust: EvaluateTrust {

	init(
		publicKeyHash: String
	) {
		self.publicKeyHash = publicKeyHash
	}

	/// Common evaluation, covering iOS versions 12.5 or 13.x
	/// - Parameters:
	///   - challenge: A challenge from a server requiring authentication from the client.
	///   - trust: Shortcut for `challenge.protectionSpace.serverTrust`
	///   - completionHandler: the completion handler to accept or reject the request
	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
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
		if
			let serverCertificate = SecTrustGetCertificateAtIndex(trust, 1),
			let serverPublicKey = SecCertificateCopyKey(serverCertificate),
			let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ) as Data? {

			// Matching fingerprint?
			let keyHash = serverPublicKeyData.sha256String()
			if publicKeyHash == keyHash {
				// Success! This is our server
				completionHandler(.useCredential, URLCredential(trust: trust))
				return
			}
		}

		completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
	}

	// MARK: - Private

	private let publicKeyHash: String

}

final class CoronaWarnURLSessionDelegate: NSObject, URLSessionDelegate {

	// MARK: - Init

	/// Initializes a CWA Session delegate
	/// - Parameter publicKeyHash: the SHA256 of the certificate to pin

	convenience init(
		publicKeyHash: String
	) {
		self.init(evaluateTrust: DefaultEvaluateTrust(publicKeyHash: publicKeyHash))
	}

	init(
		evaluateTrust: EvaluateTrust
	) {
		self.evaluateTrust = evaluateTrust
	}

	// MARK: - Protocol URLSessionDelegate

	func urlSession(
		_ session: URLSession,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		// `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
		guard let trust = challenge.protectionSpace.serverTrust else {
			// Reject all requests that we do not have a public key to pin for
			completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			return
		}
		// Apple's sample code[1] ignores the result of `SecTrustEvaluateAsyncWithError`.
		// We consider it also safe to not check for failures within `SecTrustEvaluateAsyncWithError`
		// that might return something different than `errSecSuccess`.
		//
		// [1]: https://developer.apple.com/documentation/security/certificate_key_and_trust_services/trust/evaluating_a_trust_and_parsing_the_result
		//
		// from the documentation about the method SecTrustEvaluateAsyncWithError
		// Important: You must call this method from the same dispatch queue that you specify as the queue parameter.
		//
		if #available(iOS 13.0, *) {
			let dispatchQueue = session.delegateQueue.underlyingQueue ?? DispatchQueue.global()
			dispatchQueue.async {
				SecTrustEvaluateAsyncWithError(trust, dispatchQueue) { [weak self] trust, isValid, error in
					guard isValid else {
						Log.error("Evaluation failed with error: \(error?.localizedDescription ?? "<nil>")", log: .api, error: error)
						completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
						return
					}
					self?.evaluateTrust.evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
				}
			}
		} else {
			var secresult = SecTrustResultType.invalid
			let status = SecTrustEvaluate(trust, &secresult)

			if status == errSecSuccess {
				self.evaluateTrust.evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
			} else {
				Log.error("Evaluation failed with status: \(status)", log: .api, error: nil)
				completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			}
		}
	}

	// MARK: - Private

	private let evaluateTrust: EvaluateTrust

}
