//
// 🦠 Corona-Warn-App
//

@testable import ENA
import Foundation
import XCTest
import ENASecurity

final class TrustEvaluationTests: CWATestCase {

	func testGIVEN_TrustError_WHEN_Loading_THEN_CERT_CHAIN_EMTPY() throws {

		let expectation = expectation(description: "Expect that we got an error")

		let stack = MockNetworkStack(
			sessionDelegate: CoronaWarnSessionTaskDelegate(),
			error: NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil)
		)

		let restServiceProvider = RestServiceProvider(
			session: stack.urlSession,
			cache: KeyValueCacheFake()
		)

		let trustErrorStub = TrustEvaluationErrorStub(
			error: TrustEvaluationError.CERT_CHAIN_EMTPY
		)

		let someResource = ResourceFake(
			trustEvaluation: trustErrorStub
		)

		restServiceProvider.load(someResource) { result in
			switch result {
			case .success:
				XCTFail("Failure expected.")
			case .failure(let error):
				guard case .trustEvaluationError(.CERT_CHAIN_EMTPY) = error else {
					XCTFail("VS_ID_CERT_PIN_MISMATCH error expected. Instead error received: \(error)")
					return
				}
			}
			expectation.fulfill()
		}
		waitForExpectations(timeout: .short)
	}
}
