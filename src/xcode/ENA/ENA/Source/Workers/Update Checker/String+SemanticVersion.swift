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
	private static let semanticVersionComponentFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.generatesDecimalNumbers = false
		formatter.allowsFloats = false
		return formatter
	}()

	var semanticVersion: SAP_SemanticVersion? {
		let versions: [UInt32] = components(separatedBy: ".")
			.compactMap { type(of: self).semanticVersionComponentFormatter.number(from: $0)?.intValue }
			.map(UInt32.init)

		guard versions.count == 3 else {
			return nil
		}

		return SAP_SemanticVersion.with {
			$0.major = versions[0]
			$0.minor = versions[1]
			$0.patch = versions[2]
		}
	}
}
