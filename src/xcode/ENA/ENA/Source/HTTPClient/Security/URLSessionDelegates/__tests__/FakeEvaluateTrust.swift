//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class FakeEvaluateTrust: EvaluateTrust {

	// MARK: - Init

	init(
		fakeCompletion: @escaping () -> Void
	) {
		self.fakeCompletion = fakeCompletion
	}

	// MARK: - Protocol EvaluateTrust

	func evaluate(challenge: URLAuthenticationChallenge, trust: SecTrust, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		fakeCompletion()
	}
	
	// MARK: - Private
	
	var trustEvaluationError: Error?

	// MARK: - Internal

	let fakeCompletion: () -> Void
}
