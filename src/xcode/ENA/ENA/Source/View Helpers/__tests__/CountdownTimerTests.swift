//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class CountdownTimerTests: XCTestCase {

	private var countdownTimerTarget: CountdownTimerTarget!

	override func setUp() {
		super.setUp()
		countdownTimerTarget = CountdownTimerTarget()
	}

	func test_callsDone() {
		let end = Date().addingTimeInterval(1)
		let c = CountdownTimer(countdownTo: end)
		c.delegate = countdownTimerTarget

		let expectation = self.expectation(description: "Calls done.")
		countdownTimerTarget.doneCallback = { _, _ in
			XCTAssertGreaterThan(Date(), end)
			expectation.fulfill()
		}

		c.start()
		self.waitForExpectations(timeout: .long)
	}

	func test_callsDoneWhenEndInPast() {
		let end = Date.distantPast
		let c = CountdownTimer(countdownTo: end)
		c.delegate = countdownTimerTarget

		let expectation = self.expectation(description: "Calls done when end in past.")
		countdownTimerTarget.doneCallback = { _, _ in
			expectation.fulfill()
		}

		c.start()
		self.waitForExpectations(timeout: .long)
	}

	func test_countsDown() {
		let end = Date().addingTimeInterval(3.0)
		let c = CountdownTimer(countdownTo: end)
		c.delegate = countdownTimerTarget

		let updateExpectation = self.expectation(description: "Calls update every second.")
		updateExpectation.expectedFulfillmentCount = 3
		countdownTimerTarget.updateCallback = { _, _ in
			updateExpectation.fulfill()
		}

		let doneExpectation = self.expectation(description: "Calls done when finished.")
		countdownTimerTarget.doneCallback = { _, finished in
			XCTAssertTrue(finished)
			doneExpectation.fulfill()
		}

		c.start()
		self.waitForExpectations(timeout: .extraLong) // just add enough buffer
	}
}

private class CountdownTimerTarget: CountdownTimerDelegate {

	var updateCallback: ((CountdownTimer, String) -> Void)?
	var doneCallback: ((CountdownTimer, Bool) -> Void)?

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		self.updateCallback?(timer, time)
	}

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		self.doneCallback?(timer, done)
	}
}
