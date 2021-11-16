//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class DynamicPinningSessionDelegate: NSObject, URLSessionDelegate {

	// MARK: - Init

	init(
		jwkSet: [Data],
		trustEvaluation: TrustEvaluation = TrustEvaluation()
	) {
		self.jwkSet = jwkSet
		self.trustEvaluation = trustEvaluation
	}

	// MARK: - Overrides

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
					self?.evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
				}
			}
		} else {
			var secresult = SecTrustResultType.invalid
			let status = SecTrustEvaluate(trust, &secresult)

			if status == errSecSuccess {
				self.evaluate(challenge: challenge, trust: trust, completionHandler: completionHandler)
			} else {
				Log.error("Evaluation failed with status: \(status)", log: .api, error: nil)
				completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			}
		}

	}

	// MARK: - Private

	private var jwkSet: [Data]
	private let trustEvaluation: TrustEvaluation

	private func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
#if DEBUG
		// debug/review: print the chain
		for i in 0..<SecTrustGetCertificateCount(trust) {
			if let cert = SecTrustGetCertificateAtIndex(trust, i) {
				Log.debug("[\(challenge.protectionSpace.host)] @ \(i): \(cert)", log: .crypto)
			}
		}
#endif
		let result = trustEvaluation.check(trust: trust, against: jwkSet)
		switch result {
		case .success:
			completionHandler(.useCredential, URLCredential(trust: trust))
		case .failure(let error):
			Log.debug("AuthenticationChallenge failed with error \(error.localizedDescription)", log: .client)
			completionHandler(.cancelAuthenticationChallenge, nil)
		}
	}

}
