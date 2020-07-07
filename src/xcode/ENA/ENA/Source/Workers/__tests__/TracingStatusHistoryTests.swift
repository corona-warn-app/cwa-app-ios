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
		// If tracing hisstory is empty, a state should only be added if it is good
		XCTAssertTrue(history.isEmpty)
		history = history.consumingState(goodState)
		XCTAssertEqual(history.count, 1)
		history = history.consumingState(goodState)
		history = history.consumingState(goodState)
		XCTAssertEqual(history.count, 1)
		history = history.consumingState(badState)
		XCTAssertEqual(history.count, 2)
    }

	// MARK: - TracingStatusHistory Pruning (discarding old items)

	func testPrune_Old() throws {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -15)))
		history = history.consumingState(badState, Date().addingTimeInterval(.init(days: -10)))
		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -1)))
		history = history.consumingState(badState, Date().addingTimeInterval(.init(hours: -1)))

		XCTAssertEqual(history.count, 4)
	}


	func testPrune_WithoutAutoPruning() {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -16)))
		history = history.consumingState(badState, Date().addingTimeInterval(.init(days: -15)))
		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -10)))
		history = history.consumingState(badState, Date().addingTimeInterval(.init(days: -1)))
		history = history.consumingState(goodState, Date().addingTimeInterval(.init(hours: -1)))

		XCTAssertEqual(history.count, 5)
	}

	func testPrune_KeepSingleItem() {
		// Test case when user has not changed exposure tracking for a long time
		// We should keep the oldest state (as long as it is good/on)
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -20)))

		XCTAssertEqual(history.count, 1)
	}

	// MARK: - TracingStatusHistory Risk Calculation Condition Checking
	// RiskLevel calculations require that tracing has been on for at least 24 hours

	func testIfTracingActiveForThresholdDuration_EnabledDistantPast() throws {
		// Test the simple case where the user enabled notification tracing,
		// and just left it enabled
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -20)))

		XCTAssertTrue(history.checkIfEnabled())
	}

	func testIfTracingActiveForThresholdDuration_DisabledDistantPast() throws {
		// Test the simple case where the user disabling notification tracing,
		// and just left it disabled
		var history = TracingStatusHistory()
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)

		history = history.consumingState(badState, Date().addingTimeInterval(.init(days: -20)))

		XCTAssertFalse(history.checkIfEnabled())
	}

	// Test for the following issues (which all have the same root cause)
	// - History got lost after 14 days: https://github.com/corona-warn-app/cwa-app-ios/issues/805
	// - Number of active days is misleading: https://github.com/corona-warn-app/cwa-app-ios/issues/794
	// - Fehlerhafte Zählung der aktiven Tage: https://github.com/corona-warn-app/cwa-app-ios/issues/804
	func testKeepsMostRecentIrrelevantItem() {
		var history = TracingStatusHistory()
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		var date = Date().addingTimeInterval(.init(days: -15))
		history = history.consumingState(goodState, date)

		date = date.addingTimeInterval(.init(days: 13))
		history = history.consumingState(badState, date)

		history = history.consumingState(goodState, date)

		XCTAssertEqual(history.activeTracing().inDays, 14)
	}

	func testIfTracingActiveForThresholdDuration_EnabledClosePast() throws {
		// Test the simple case where the user enabled notification tracing not too long ago,
		// and just left it enabled
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(hours: -20)))

		XCTAssertFalse(history.checkIfEnabled())
	}

	func testIfTracingActiveForThresholdDuration_Toggled() throws {
		// Test the case where the user repeatedly enabled and disabled tracking
		var history = TracingStatusHistory()
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		var date = Date().addingTimeInterval(.init(hours: -30))

		// User enabled the tracing 30 hours ago
		history = history.consumingState(goodState, date)
		XCTAssertFalse(history.checkIfEnabled(since: date))

		date = date.addingTimeInterval(.init(hours: 1))

		// User turned it off after one hour - we've been tracing for one hour
		history = history.consumingState(badState, date)
		XCTAssertFalse(history.checkIfEnabled(since: date))

		date = date.addingTimeInterval(.init(hours: 2))

		// User leaves off for two hours - we've been tracing for one hour
		history = history.consumingState(goodState, date)
		XCTAssertFalse(history.checkIfEnabled(since: date))

		date = date.addingTimeInterval(.init(hours: 20))

		// User leaves it on for 20 hours - We've been tracking for 21 hours
		XCTAssertFalse(history.checkIfEnabled(since: date))

		// User leaves it on up and including until now
		XCTAssertTrue(history.checkIfEnabled())
	}

	// MARK: - Tracing enabled days tests

	func testEnabledDaysCount_EnabledDistantPast() throws {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(.init(days: -10)))

		XCTAssertEqual(history.activeTracing().inDays, 10)
	}

	func testEnabledDaysCount_EnabledRecently() throws {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(-10))

		XCTAssertEqual(history.activeTracing().inDays, 0)
	}

	func testEnabledHoursCount_EnabledRecently() throws {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		history = history.consumingState(goodState, Date().addingTimeInterval(-5400))

		let activeTracing = history.activeTracing()

		XCTAssertEqual(activeTracing.interval, 5400, accuracy: 0.1)
		// Enabled for 1.5 hours should only count as 1 enabled hour (truncating)
		XCTAssertEqual(activeTracing.inHours, 1)
	}

	func testEnabledHoursCount_WithTheFirstEntryBeingInDistantPast() throws {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)

		let now = Date()

		history = history.consumingState(goodState, now.addingTimeInterval(.init(days: -100)))
		history = history.consumingState(badState, now.addingTimeInterval(.init(days: -10)))	// stop being active after 4 days

		let activeTracing = history.activeTracing(since: now)

		XCTAssertEqual(activeTracing.interval, 96 * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inDays, 4)
		XCTAssertEqual(activeTracing.inHours, 96)
	}


	func testEnabledHoursCount_Complex() {
		var history = TracingStatusHistory()
		let goodState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		let badState = ExposureManagerState(authorized: true, enabled: false, status: .active)

		let now = Date()

		history = history.consumingState(goodState, now.addingTimeInterval(.init(days: -15)))
		history = history.consumingState(badState, now.addingTimeInterval(.init(days: -10)))	// active for 5 days (where one day is 'irrelevant'
		history = history.consumingState(goodState, now.addingTimeInterval(.init(days: -1))) // inactive for 9 days
		history = history.consumingState(badState, now.addingTimeInterval(.init(hours: -1)))	// active for 23 hours

		let activeTracing = history.activeTracing(since: now)
		XCTAssertEqual(activeTracing.interval, (24 * 4 + 23) * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inHours, 24 * 4 + 23)
		XCTAssertEqual(activeTracing.inDays, 5)
	}

	func testGetEnabledInterval_Accumulator_Good() {
		let now = Date()

		let history: TracingStatusHistory = [
			.init(on: true, date: now.addingTimeInterval(.init(days: -10))),
			.init(on: true, date: now.addingTimeInterval(.init(days: -5)))
		]

		let activeTracing = history.activeTracing(since: now)

		XCTAssertEqual(activeTracing.interval, 24 * 10 * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inDays, 10)
	}

	func testGetEnabledInterval_Accumulator_Good_2() {
		let now = Date()

		let history: TracingStatusHistory = [
			.init(on: true, date: now.addingTimeInterval(.init(days: -10))),
			.init(on: true, date: now.addingTimeInterval(.init(days: -5))),
			.init(on: true, date: now.addingTimeInterval(.init(days: -3))),
			.init(on: true, date: now.addingTimeInterval(.init(days: -1)))
		]

		let activeTracing = history.activeTracing(since: now)

		XCTAssertEqual(activeTracing.interval, 24 * 10 * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inDays, 10)
	}

	func testGetEnabledInterval_Accumulator_Good_3() {
		let now = Date()

		let history: TracingStatusHistory = [
			.init(on: true, date: now.addingTimeInterval(.init(days: -10))),
			.init(on: false, date: now.addingTimeInterval(.init(days: -5))),	// Active for 5 days
			.init(on: true, date: now.addingTimeInterval(.init(days: -2)))		// Inactive for 3 days
			// Active for 2 more days
		]

		let activeTracing = history.activeTracing(since: now)

		XCTAssertEqual(activeTracing.interval, 24 * 7 * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inDays, 7)
	}

	func testGetEnabledInterval_Accumulator_Bad() {
		let now = Date()

		let history: TracingStatusHistory = [
			.init(on: false, date: now.addingTimeInterval(.init(days: -10))),
			.init(on: false, date: now.addingTimeInterval(.init(days: -5))),
			.init(on: true, date: now.addingTimeInterval(.init(days: -2)))
		]

		let activeTracing = history.activeTracing(since: now)

		XCTAssertEqual(activeTracing.interval, 24 * 2 * 3600, accuracy: 0.1)
		XCTAssertEqual(activeTracing.inDays, 2)
	}

	func testNumberOfDays_Rounding() {
		let now = Date()

		var history: TracingStatusHistory = [
			.init(on: true, date: now.addingTimeInterval(.init(hours: -((24 * 5) + 4))))
		]

		XCTAssertEqual(history.activeTracing(since: now, maximumNumberOfDays: 14).inDays, 5)

		history = [
			.init(on: true, date: now.addingTimeInterval(.init(hours: -((24 * 5) + 13))))
		]
		XCTAssertEqual(history.activeTracing(since: now, maximumNumberOfDays: 14).inDays, 6)

		history = [
			.init(on: true, date: now.addingTimeInterval(.init(hours: -((24 * 5) + 0))))
		]
		XCTAssertEqual(history.activeTracing(since: now, maximumNumberOfDays: 14).inDays, 5)
	}
}

private extension TimeInterval {
	init(hours: Int) {
		self = Double(hours * 60 * 60)
	}

	init(days: Int) {
		self = Double(days * 24 * 60 * 60)
	}
}
