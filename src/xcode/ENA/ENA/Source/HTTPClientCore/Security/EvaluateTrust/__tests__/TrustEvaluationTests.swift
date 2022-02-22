//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import ENASecurity

final class TrustEvaluationTests: CWATestCase {

	func testGIVEN_TrustError_WHEN_Loading_THEN_CERT_MISMATCH() throws {

		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			sessionDelegate: CoronaWarnSessionTaskDelegate(),
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let trustErrorStub = DefaultTrustEvaluation(publicKeyHash: "trash")

		let someResource = ResourceFake(
			trustEvaluation: trustErrorStub
		)

		restServiceProvider.load(someResource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .trustEvaluationError(.default(.CERT_MISMATCH)) = error else {
					XCTFail("CERT_MISMATCH error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
}
