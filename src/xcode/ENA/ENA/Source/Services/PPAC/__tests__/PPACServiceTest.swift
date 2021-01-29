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
			_ = try PrivacyPreservingAccessControlService(store: store)
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
			_ = try PrivacyPreservingAccessControlService(store: store)
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
			let ppacService = try PrivacyPreservingAccessControlService(store: store)
			// THEN
			XCTAssertNotNil(ppacService)

		} catch PPACError.deviceNotSupported {
			XCTFail("device not supported")
		} catch {
			XCTFail("unexpected error")
		}
	}

}
