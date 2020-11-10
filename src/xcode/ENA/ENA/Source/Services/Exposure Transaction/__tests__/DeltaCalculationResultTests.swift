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

@testable import ENA
import XCTest

final class DeltaCalculationResultTests: XCTestCase {
	func testMissingDays_EmptyStore() {
		let emptyDelta = DeltaCalculationResult(
			remoteDays: [],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(emptyDelta.missingDays, [])
		XCTAssertEqual(emptyDelta.missingHours, [])

		let singleRemoteDay = DeltaCalculationResult(
			remoteDays: ["a"],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(singleRemoteDay.missingDays, ["a"])
		XCTAssertEqual(singleRemoteDay.missingHours, [])

		let multipleRemoteDays = DeltaCalculationResult(
			remoteDays: ["a", "b"],
			remoteHours: [],
			localDays: [],
			localHours: []
		)
		XCTAssertEqual(multipleRemoteDays.missingDays, ["a", "b"])
		XCTAssertEqual(multipleRemoteDays.missingHours, [])
	}

	func testMissingDays() {
		let delta = DeltaCalculationResult(
			remoteDays: ["a", "b"],
			remoteHours: [],
			localDays: ["b"],
			localHours: []
		)

		XCTAssertEqual(delta.missingDays, ["a"])
		XCTAssertEqual(delta.missingHours, [])
	}

	func testMissingHours() {
		let delta = DeltaCalculationResult(
			remoteDays: [],
			remoteHours: [1, 2, 3, 4],
			localDays: [],
			localHours: [2]
		)

		XCTAssertEqual(delta.missingDays, [])
		XCTAssertEqual(delta.missingHours, [1, 3, 4])
	}
}
