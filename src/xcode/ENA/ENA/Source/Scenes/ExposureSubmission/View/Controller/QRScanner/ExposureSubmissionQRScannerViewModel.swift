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

import Foundation
import UIKit

struct ExposureSubmissionQRScannerViewModel {

	// MARK: - Internal

	/// Sanitizes the input string and extracts a guid.
	/// - the input needs to start with https://localhost/?
	/// - the input must not ne longer than 150 chars and cannot be empty
	/// - the guid contains only the following characters: a-f, A-F, 0-9,-
	/// - the guid is a well formatted string (6-8-4-4-4-12) with length 43
	///   (6 chars encode a random number, 32 chars for the uuid, 5 chars are separators)
	func extractGuid(from input: String) -> String? {
		guard
			!input.isEmpty,
			input.count <= 150,
			let regex = try? NSRegularExpression(
				pattern: "^https:\\/\\/localhost\\/\\?(?<GUID>[0-9A-Fa-f]{6}-[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12})$"
			),
			let match = regex.firstMatch(in: input, options: [], range: NSRange(location: 0, length: input.utf8.count))
		else { return nil }

		guard let range = Range(match.range(withName: "GUID"), in: input) else { return nil }

		let candidate = String(input[range])
		guard !candidate.isEmpty, candidate.count == 43 else { return nil }

		return candidate
	}

}
