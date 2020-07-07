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

import XCTest
@testable import ENA

final class ActiveTracingTests: XCTestCase {
    func testOneHour() {
		let activeTracing = _activeTracing(interval: 3600)
		XCTAssertEqual(activeTracing.interval, 3600, accuracy: .high)
		XCTAssertEqual(activeTracing.inDays, 0)
	}

	func testThatLessThan12HoursDontCountAsDay() {
		XCTAssertEqual(
			_activeTracing(interval: 3600 * 11).inDays,
			0
		)
		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * 11.9).inDays,
			0
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 11)).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 11.99)).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 * 10 + 11.5)).inDays,
			10
		)
	}

	func testThatMoreThan12HoursCountAsDay() {
		XCTAssertEqual(
			_activeTracing(interval: 3600 * 12).inDays,
			1
		)
		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * 12.1).inDays,
			1
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 12)).inDays,
			2
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 + 12.01)).inDays,
			2
		)

		XCTAssertEqual(
			_activeTracing(interval: 3600.0 * (24 * 10 + 12.5)).inDays,
			11
		)
	}
}

private func _activeTracing(interval: TimeInterval) -> ActiveTracing {
	ActiveTracing(interval: interval, maximumNumberOfDays: 14)
}

private extension TimeInterval {
	static let high = 0.1
}
