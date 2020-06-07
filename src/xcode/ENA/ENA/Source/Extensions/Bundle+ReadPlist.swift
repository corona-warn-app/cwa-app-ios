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

extension Bundle {
	/// Read the Plist with the specified name as a `[String: String]` dictionary
	///
	/// - returns: Dictionary with `String` K/V pairs, nil if the plist was not found in the Bundle
	func readPlistDict(name: String) -> [String: String]? {
		guard
			let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let plistDict = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainers, format: nil) as? [String: String]
		else {
			return nil
		}

		return plistDict
	}

	/// Read the Plist with the specified name as a `[String]` array
	///
	/// - returns:`String` Array of the plist contents
	func readPlistAsArr(name: String) -> [String]? {
		guard
			let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let plistArr = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainers, format: nil) as? [String]
		else {
			return nil
		}

		return plistArr
	}
}
