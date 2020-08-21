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

import Foundation

struct TracingStatusEntry: Codable {
	let on: Bool
	let date: Date
}

typealias TracingStatusHistory = [TracingStatusEntry]

extension Array where Element == TracingStatusEntry {
	// MARK: Creating a Tracting Status History from JSON encoded data
	static func from(data: Data) throws -> TracingStatusHistory {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .secondsSince1970
		return try decoder.decode(self, from: data)
	}

	// MARK: Getting a JSON encoded data representation
	func JSONData() throws -> Data {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .secondsSince1970
		return try encoder.encode(self)
	}

	// MARK: Adjusting the History based on a new State reported by the Exposure Notification framework
	func consumingState(_ state: ExposureManagerState, _ date: Date = Date()) -> TracingStatusHistory {
		let newEntry = TracingStatusEntry(on: state.isGood, date: date)
		var copy = self
		guard let lastEntry = last else {
			if state.isGood {
				copy.append(newEntry)
			}
			return copy
		}
		if lastEntry.on != newEntry.on {
			copy.append(newEntry)
		}
		return copy
	}

	struct PrunedEntries {
		let relevant: [TracingStatusEntry]
		let lastIrrelevant: TracingStatusEntry?
	}

	// MARK: - Prune stale elements older than 14 days
	/// Clean up `[TracingStatusEntry]` so we do not store entries past the threshold (14 days)
	///
	/// - parameter threshold: Max seconds entries can be in the past for. Defaults to 14 days
	private func pruned(with threshold: TimeInterval = Self.maxStoredSeconds) -> PrunedEntries {
		let maxPast = Date().addingTimeInterval(-threshold)
		let relevantEntries = filter { $0.date > maxPast }
		let irrelevantEntries = filter { $0.date <= maxPast }
		return .init(relevant: relevantEntries, lastIrrelevant: irrelevantEntries.last)
	}

	// MARK: - Check Tracing History for Risk Calculation

	/// Check the `TracingStatusHistory` if it has been turned on for `timeInterval` seconds
	///
	/// Typically used to check the tracing duration precondition for risk calculation
	/// - parameter timeInterval: Seconds to use as the threshold. Defaults to 24 hours.
	/// - parameter date: Date to use as the baseline. Defaults to `Date()`
	func checkIfEnabled(
		for continuousInterval: TimeInterval = Self.minimumActiveSeconds,
		since date: Date = Date()
	) -> Bool {
		getContinuousEnabledInterval(since: date) > continuousInterval
	}

	/// Mark returns the active tracing info.
	///
	/// - parameter since: Date to use as the baseline. Defaults to `Date()`
	/// - parameter maximumNumberOfDays: Maximum number of days we keep in the history.
	func activeTracing(
		since date: Date = Date(),
		maximumNumberOfDays: Int = Self.maxStoredDays
	) -> ActiveTracing {
		#if UITESTING
		return ActiveTracing(
			interval: .init(336 * 3600),  // two weeks,
			maximumNumberOfDays: maximumNumberOfDays
		)
		#else
		return ActiveTracing(
			interval: getContinuousEnabledInterval(since: date),
			maximumNumberOfDays: maximumNumberOfDays
		)
		#endif
	}

	/// Get the total `TimeInterval` that tracing has been enabled.
	///
	/// - parameter since: `Date` to use as the baseline. Defaults to `Date()`
	private func getContinuousEnabledInterval(since: Date = Date()) -> TimeInterval {
		// In order to have a minimal set of changes for hotfix #1 we hard-code
		// the precondition (self is pruned) here and have the old, tested code
		// stay the same in _getContinuousEnabledInterval.
		let prunedEntries = pruned()

		let intervalForRelevantEntries = prunedEntries.relevant._getContinuousEnabledInterval(since: since)

		let oldestRelevantDate = prunedEntries.relevant.first?.date ?? since
		if prunedEntries.lastIrrelevant?.on == true {
			let now = since
			let earliestPotentialDate = now.addingTimeInterval(-Self.maxStoredSeconds)
			let delta = oldestRelevantDate.timeIntervalSince(earliestPotentialDate)
			return intervalForRelevantEntries + delta
		}

		return intervalForRelevantEntries
	}

	private func _getContinuousEnabledInterval(since: Date = Date()) -> TimeInterval {
		// self is pruned
		guard !isEmpty else {
			return .zero
		}
		var prevDate = since
		// Assume pruned array
		return reversed().reduce(.zero) { acc, next -> TimeInterval in
			if next.on {
				let sum = acc + prevDate.timeIntervalSince(next.date)
				prevDate = next.date
				return sum
			}
			prevDate = next.date
			return acc
		}
	}

	// MARK: - Constants for Tracing

	/// The minimum count of hours tracing must have been active for risk calculation to work
	static let minimumActiveHours = 24
	/// The minimum count of seconds tracing must have been active for risk calculation to work
	static var minimumActiveSeconds: TimeInterval { TimeInterval(minimumActiveHours * 60 * 60) }
	/// The maximum count of days to keep tracing history for
	static let maxStoredDays = 14
	/// The maximum count of seconds to keep tracing history for
	static var maxStoredSeconds: TimeInterval { TimeInterval(maxStoredDays * 24 * 60 * 60) }
}
