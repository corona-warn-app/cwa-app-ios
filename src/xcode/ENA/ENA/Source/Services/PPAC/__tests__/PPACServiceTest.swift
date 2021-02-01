////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class PPACServiceTest: XCTestCase {

	func testGIVEN_DeviceTimeIsIncorract_WHEN_InitPPACService_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		store.deviceTimeCheckResult = .incorrect
		let failedExpectation = expectation(description: "Init failed")

		// WHEN
		do {
			_ = try PPACService(store: store)
		} catch PPACError.timeIncorrect {
			failedExpectation.fulfill()
		} catch {
			XCTFail("unexpected error")
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsAssumeCorrect_WHEN_InitPPACService_THEN_FailWithError() {
		// GIVEN
		let store = MockTestStore()
		store.deviceTimeCheckResult = .assumedCorrect
		let failedExpectation = expectation(description: "Init failed")

		// WHEN
		do {
			_ = try PPACService(store: store)
		} catch PPACError.timeUnverified {
			failedExpectation.fulfill()
		} catch {
			XCTFail("unexpected error")
		}

		// THEN
		wait(for: [failedExpectation], timeout: .medium)
	}

	func testGIVEN_DeviceTimeIsCorrect_WHEN_InitPPACService_THEN_Success() {
		// GIVEN
		let store = MockTestStore()
		store.deviceTimeCheckResult = .correct

		// WHEN
		do {
			let ppacService = try PPACService(store: store)
			// THEN
			XCTAssertNotNil(ppacService)

		} catch PPACError.deviceNotSupported {
			XCTFail("device not supported")
		} catch {
			XCTFail("unexpected error")
		}
	}

	func testGIVEN_StoreHasNoAPIToken_WHEN_getPPACToken_THEN_APITokenIsInStore() throws {
		// GIVEN
		let store = MockTestStore()
		store.deviceTimeCheckResult = .correct
		let ppacExpectation = expectation(description: "Init failed")

		// WHEN

		let ppacService = try? XCTUnwrap(PPAServiceMock(store: store))
		ppacService?.getPPACToken({ result in
			switch result {
			case let .success(ppaToken):
				ppacExpectation.fulfill()
				XCTAssertNotNil(store.ppacApiToken)
				XCTAssertEqual(store.ppacApiToken?.token, ppaToken.apiToken)

			case .failure:
				XCTFail("Unexpected error happend")
			}
		})

		// THEN
		wait(for: [ppacExpectation], timeout: .long)
	}

}
