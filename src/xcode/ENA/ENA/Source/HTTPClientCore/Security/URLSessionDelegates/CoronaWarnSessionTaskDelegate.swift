//
// 🦠 Corona-Warn-App
//

import Foundation

class CoronaWarnSessionTaskDelegate: NSObject, URLSessionTaskDelegate {
	
	// MARK: - Protocol URLSessionTaskDelegate

	func urlSession(
		_ session: URLSession,
		task: URLSessionTask,
		didReceive challenge: URLAuthenticationChallenge,
		completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
	) {
		
		// If there is no trust evaluation or the trust evaluation is DisabledTrustEvaluation, perform default handling - as if this delegate were not implemented.
		guard var trustEvaluation = trustEvaluations[task.taskIdentifier],
			  !(trustEvaluation is DisabledTrustEvaluation) else {
			completionHandler(.performDefaultHandling, nil)
			return
		}
		
		// `serverTrust` not nil implies that authenticationMethod == NSURLAuthenticationMethodServerTrust
		guard let trust = challenge.protectionSpace.serverTrust else {
			trustEvaluation.trustEvaluationError = .notSupportedAuthenticationMethod
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
				SecTrustEvaluateAsyncWithError(trust, dispatchQueue) { trust, isValid, error in
					guard isValid else {
						Log.error("Evaluation failed with error: \(error?.localizedDescription ?? "<nil>")", log: .api, error: error)
						trustEvaluation.trustEvaluationError = .invalidSecTrust
						completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
						return
					}
					trustEvaluation.evaluate(
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
				trustEvaluation.evaluate(
					challenge: challenge,
					trust: trust,
					completionHandler: completionHandler
				)
			} else {
				Log.error("Evaluation failed with status: \(status)", log: .api, error: nil)
				trustEvaluation.trustEvaluationError = .invalidSecTrust
				completionHandler(.cancelAuthenticationChallenge, /* credential */ nil)
			}
		}
		
		trustEvaluations[task.taskIdentifier] = nil
	}
	
	// MARK: - Internal

	var trustEvaluations: [Int: TrustEvaluating] {
		get { trustEvaluationsQueue.sync { _trustEvaluations } }
		set { trustEvaluationsQueue.sync { _trustEvaluations = newValue } }
	}

	// MARK: - Private
	
	// Serial queue for safe access of trustEvaluations.
	private let trustEvaluationsQueue = DispatchQueue(label: "com.sap.CoronaWarnSessionTaskDelegate.trustEvaluationsQueue")

	// Map the trust evaluations to the tasks.
	// This way every task has its own trust evaluation.
	private var _trustEvaluations = [Int: TrustEvaluating]()

}
