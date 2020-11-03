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

struct CWARange: Decodable {

	// MARK: - Internal

	let min: Double
	let max: Double

	let minExclusive: Bool?
	let maxExclusive: Bool?

	func contains(_ value: Double) -> Bool {
		let minExclusive = self.minExclusive ?? false
		let maxExclusive = self.maxExclusive ?? false

		if minExclusive && value <= min { return false }
		if !minExclusive && value < min { return false }
		if maxExclusive && value >= max { return false }
		if !maxExclusive && value > max { return false }

		return true
	}

	func contains(_ value: Int) -> Bool {
		contains(Double(value))
	}

	func contains(_ value: UInt8) -> Bool {
		contains(Double(value))
	}

}
