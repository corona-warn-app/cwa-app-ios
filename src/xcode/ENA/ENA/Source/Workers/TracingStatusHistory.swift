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
		let newEntry = TracingStatusEntry(on: state.isGood, date: Date())
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
		return copy.pruned()
	}

	// MARK: - Check Tracing History for Risk Calculation
	/// Check the `TracingStatusHistory` if it has been turned on for `timeInterval` seconds
	///
	/// Typically used to check if risk calculation can work
	func checkIfOn(for timeInterval: TimeInterval = 14 * 24 * 60 * 60) -> Bool {
		guard !isEmpty else {
			return false
		}

		var prevDate = Date()
		// Assume pruned array
		let sum = reversed().reduce(TimeInterval.zero) { acc, next -> TimeInterval in
			if next.on {
				let sum = acc + prevDate.timeIntervalSince(next.date)
				prevDate = next.date
			}
			return acc
		}

		return sum > timeInterval
	}

	// MARK: - Prune stale elements older than 14 days
	/// Clean up any `TracingStatusEntry` older than THRESHOLD
	func pruned() -> TracingStatusHistory {
		let now = Date()
		let threshold: TimeInterval = 14 * 24 * 60 * 60		// 14 days in seconds. TODO: Put in enum/constant somewhere

		// Iterate from end of array until we find a date older than THRESHOLD
		var firstStaleIndex: Int?
		for (i, element) in enumerated().reversed() {
			if now.timeIntervalSince(element.date) > threshold {
				firstStaleIndex = i
				break
			}
		}

		guard let staleIndex = firstStaleIndex else {
			return self
		}
		// Should probably leave one element in
		return Array(self[staleIndex...])
	}
}
