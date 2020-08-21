//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import XCTest
@testable import ENA

class CountdownTimerTests: XCTestCase {

	private var countdownTimerTarget: CountdownTimerTarget!

	override func setUp() {
		countdownTimerTarget = CountdownTimerTarget()
	}

	func test_callsDone() {
		let end = Date().addingTimeInterval(1)
		let c = CountdownTimer(countdownTo: end)
		c.delegate = countdownTimerTarget

		let expectation = self.expectation(description: "Calls done.")
		countdownTimerTarget.doneCallback = { _, _ in
			XCTAssert(Date() > end)
			expectation.fulfill()
		}

		c.start()
		self.waitForExpectations(timeout: 3.0)
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
		self.waitForExpectations(timeout: 3.0)
	}

	func test_countsDown() {
		let end = Date().addingTimeInterval(3.0)
		let c = CountdownTimer(countdownTo: end)
		c.delegate = countdownTimerTarget

		let updateExpectation = self.expectation(description: "Calls update every second.")
		updateExpectation.expectedFulfillmentCount = 3
		countdownTimerTarget.updateCallback = { _, time in
			updateExpectation.fulfill()
		}

		let doneExpectation = self.expectation(description: "Calls done when finished.")
		countdownTimerTarget.doneCallback = { _, _ in
			doneExpectation.fulfill()
		}

		c.start()
		self.waitForExpectations(timeout: 5.0)
	}
}

class CountdownTimerTarget: CountdownTimerDelegate {

	var updateCallback: ((CountdownTimer, String) -> Void)?
	var doneCallback: ((CountdownTimer, Bool) -> Void)?

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		self.updateCallback?(timer, time)
	}

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		self.doneCallback?(timer, done)
	}
}
