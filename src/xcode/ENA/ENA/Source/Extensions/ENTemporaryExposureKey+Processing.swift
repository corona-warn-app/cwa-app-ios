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
import ExposureNotification

extension Array where Element: ENTemporaryExposureKey {
	/// The maximum number of keys to be submitted
	var maxKeyCount: Int { 14 }
	/// Transmission risk level by days since the exposure.
	/// These factors are applied to each `ENTemporaryExposureKey`'s `transmissionRiskLevel`
	///
	/// Index 0 of the array represents the day of the exposure
	/// Index 1 the next day, and so on.
	/// These factors are supplied by RKI
	///
	/// - see also: [Risk Score Calculation Docs](https://github.com/corona-warn-app/cwa-documentation/blob/master/solution_architecture.md#risk-score-calculation)
	var transmissionRiskDefaultVector: [ENRiskLevel] {
		// TODO: Is this vector not one too long (extra 1 at end)?
		// TODO: Can we assume/clamp the vector to `maxKeyCount` # of elements?
		[5, 6, 8, 8, 8, 5, 3, 1, 1, 1, 1, 1, 1, 1, 1]
	}

	/// In-place prepare an array of `ENTemporaryExposureKey` for exposure submission.
	///
	/// Performs the following steps:
	/// 1. Sorts the keys by their `rollingStartNumber`
	/// 2. Takes the first `maxKeyCount` (14) keys using `prefix(_ :)`
	/// 3. Applies the `transmissionRiskDefaultVector` to the sorted keys
	mutating func processedForSubmission() {

		sort {
			$0.rollingStartNumber > $1.rollingStartNumber
		}

		if count > 14 {
			self = Array(self[0 ..< 14])
		}

		let startIndex = 0
		for i in startIndex...self.count - 1 {
			if i + 1 <= transmissionRiskDefaultVector.count - 1 {
				// TODO: Why do we get the i+1 element? This means we never get the first element in our vector!
				self[i].transmissionRiskLevel = UInt8(transmissionRiskDefaultVector[i + 1])
			} else {
				// TODO: Will this case actually ever happen? We clamp the key array to 14 elements
				// Assuming that this case does not happen let's us simplify this logic with a for loop and zip
				self[i].transmissionRiskLevel = UInt8(1)
			}
		}
		// Slight refactor, but DIFFERENT behavior than above
//		sort {
//			$0.rollingStartNumber > $1.rollingStartNumber
//		}
//
//		self = Array(prefix(maxKeyCount))
//		// We assume that the vector and key array have the same length
//		for (key, vectorElement) in zip(self, transmissionRiskDefaultVector) {
//			key.transmissionRiskLevel = vectorElement
//		}
	}
}
