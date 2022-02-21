//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class FakeEvaluateTrust: TrustEvaluating {

	// MARK: - Init

	init(
		fakeCompletion: @escaping () -> Void
	) {
		self.fakeCompletion = fakeCompletion
	}

	// MARK: - Protocol TrustEvaluating

	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		fakeCompletion()
	}
	
	// MARK: - Private
	
	var trustEvaluationError: Error?

	// MARK: - Internal

	let fakeCompletion: () -> Void
}
