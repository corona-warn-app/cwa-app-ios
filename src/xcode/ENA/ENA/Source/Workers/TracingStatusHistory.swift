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
	func consumingState(_ state: ExposureManagerState) -> TracingStatusHistory {
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
		return copy
	}
}
