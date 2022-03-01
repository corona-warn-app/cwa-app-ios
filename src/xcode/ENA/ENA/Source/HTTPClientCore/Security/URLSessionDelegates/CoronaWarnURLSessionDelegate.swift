//
// 🦠 Corona-Warn-App
//

import Foundation
import ENASecurity

final class CoronaWarnURLSessionDelegate: NSObject, URLSessionDelegate {

	// MARK: - Init

	/// Initializes a CWA Session delegate
	/// - Parameter publicKeyHash: the SHA256 of the certificate to pin

	init(
		evaluateTrust: TrustEvaluating
	) {
		self.evaluateTrust = evaluateTrust
	}

	convenience init(
		publicKeyHash: String
	) {
		self.init(
			evaluateTrust: DefaultTrustEvaluation(
				publicKeyHash: publicKeyHash
			)
		)
	}

	convenience init(
		jwkSet: [JSONWebKey],
		trustEvaluation: ENASecurity.JSONWebKeyTrustEvaluation = ENASecurity.JSONWebKeyTrustEvaluation()
	) {
		self.init(
			evaluateTrust: JSONWebKeyTrustEvaluation(
				jwkSet: jwkSet,
				trustEvaluation: trustEvaluation
			)
		)
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
					self?.evaluateTrust.evaluate(
						challenge: challenge,
						trust: trust,
						completionHandler: completionHandler
					)
				}
			}
		} else {
			var secresult = SecTrustResultType.invalid
			let status = SecTrustEvaluate(trust, &secresult)
			
			if status == errSecSuccess {
				self.evaluateTrust.evaluate(
					challenge: challenge,
					trust: trust,
					completionHandler: completionHandler
				)
			} else {
				Log.error("Evaluation failed with status: \(status)", log: .api, error: nil)
				completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			}
		}
	}

	// MARK: - Internal

	var evaluateTrust: TrustEvaluating
}
