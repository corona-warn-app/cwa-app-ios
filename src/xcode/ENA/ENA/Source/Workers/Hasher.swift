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

import CryptoKit
import Foundation

enum Hasher {
	/// Hashes the given input string using SHA-256.
	static func sha256(_ input: String) -> String {
		let value = SHA256.hash(data: Data(input.utf8))
		let hash = value.compactMap { String(format: "%02x", $0) }.joined()
		return hash
	}
}
