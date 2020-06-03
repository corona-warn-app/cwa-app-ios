//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import XCTest
@testable import ENA

final class TracingStatusHistoryTests: XCTestCase {
    func testTracingStatusHistory() throws {
		var history = TracingStatusHistory()
		XCTAssertTrue(history.isEmpty)
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)
		history = history.consumingState(badState)
		XCTAssertTrue(history.isEmpty)
		history = history.consumingState(goodState)
		XCTAssertEqual(history.count, 1)
		history = history.consumingState(goodState)
		history = history.consumingState(goodState)
		XCTAssertEqual(history.count, 1)
		history = history.consumingState(badState)
		XCTAssertEqual(history.count, 2)
    }
}
