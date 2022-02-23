//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class URLSessionDelegate_UpdateEvaluateTrust: CWATestCase {

	func testGIVEN_restServiceProvider_THEN_OriginalEvaluateTrustGetsCalled() throws {
		// GIVEN
		let originalExpectation = expectation(description: "original evaluate expectation")
		let originalEvaluateTrust = FakeEvaluateTrust {
			originalExpectation.fulfill()
		}

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data(),
			sessionDelegate: CoronaWarnURLSessionDelegate(evaluateTrust: originalEvaluateTrust)
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		// THEN
		try XCTUnwrap(restServiceProvider.evaluateTrust as? FakeEvaluateTrust).fakeCompletion()
		waitForExpectations(timeout: .short)
	}

	func testGIVEN_restServiceProvider_WHEN_UpdateEvalueTrust_THEN_UpdatedEvaluateTrustGetsCalled() throws {
		// GIVEN
		let originalExpectation = expectation(description: "original evaluate expectation")
		originalExpectation.isInverted = true
		let originalEvaluateTrust = FakeEvaluateTrust {
			originalExpectation.fulfill()
		}

		let updatedExpectation = expectation(description: "updated evaluate expectation")
		let updatedEvaluateTrust = FakeEvaluateTrust {
			updatedExpectation.fulfill()
		}

		let stack = MockNetworkStack(
			httpStatus: 400,
			responseData: Data(),
			sessionDelegate: CoronaWarnURLSessionDelegate(evaluateTrust: originalEvaluateTrust)
		)
		let restServiceProvider = RestServiceProvider(session: stack.urlSession, cache: KeyValueCacheFake())

		// WHEN
		restServiceProvider.update(updatedEvaluateTrust)

		// THEN
		try XCTUnwrap(restServiceProvider.evaluateTrust as? FakeEvaluateTrust).fakeCompletion()
		waitForExpectations(timeout: .short)
	}

}
