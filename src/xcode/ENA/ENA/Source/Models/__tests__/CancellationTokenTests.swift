//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CancellationTokenTests: XCTestCase {
    func testCallsBlockOnCancel() throws {
		let onCancelWasCalled = expectation(description: "onCancel must be called")
		onCancelWasCalled.assertForOverFulfill = true
		let sut = CancellationToken {
			onCancelWasCalled.fulfill()
		}
		sut.cancel()
		waitForExpectations(timeout: .short)
	}
}
