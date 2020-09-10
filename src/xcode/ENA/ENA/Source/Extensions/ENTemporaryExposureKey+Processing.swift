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

	/// In-place prepare an array of `ENTemporaryExposureKey` for exposure submission.
	///
	/// Performs the following steps:
	/// 1. Sorts the keys by their `rollingStartNumber`
	/// 2. Takes the first `maxKeyCount` (14) keys using `prefix(_ :)`
	/// 3. Applies the `transmissionRiskDefaultVector` to the sorted keys
	mutating func process(for symptomsOnset: SymptomsOnset) {
		sort {
			$0.rollingStartNumber > $1.rollingStartNumber
		}

		self = Array(prefix(maxKeyCount))
		for (key, vectorElement) in zip(self, symptomsOnset.transmissionRiskVector.dropFirst()) {
			key.transmissionRiskLevel = vectorElement
		}
	}

}
