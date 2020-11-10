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

extension String {
	/// This method generates a random string containing the lowercase english alphabet letters a-z,
	/// given a specific size.
	public static func getRandomString(of size: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyz"
		var rand = ""
		for _ in 0..<size {
			rand += "\(letters.randomElement() ?? "a")"
		}
		return rand
	}
}
