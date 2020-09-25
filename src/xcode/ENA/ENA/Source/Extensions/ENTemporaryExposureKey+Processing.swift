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

	/// Prepare an array of `ENTemporaryExposureKey` for exposure submission.
	///
	/// Performs the following steps:
	/// 1. Groups the keys by their `rollingStartNumber`
	/// 2. Applies the `transmissionRiskVector` to the grouped keys
	func processedForSubmission(with symptomsOnset: SymptomsOnset, today: Date = Date()) -> [ENTemporaryExposureKey] {
		var groupedExposureKeys: [Int: Self] = Dictionary(grouping: self, by: {
			let rollingStartNumber = $0.rollingStartNumber
			let startDate = Date(timeIntervalSince1970: Double(rollingStartNumber) * 600)

			var calendar = Calendar(identifier: .gregorian)
			// swiftlint:disable:next force_unwrapping
			calendar.timeZone = TimeZone(secondsFromGMT: 0)!

			guard let daysUntilToday = calendar.dateComponents([.day], from: startDate, to: today).day else { fatalError("Getting days since rolling start day failed") }

			return daysUntilToday
		})

		for (daysUntilToday, exposureKeys) in groupedExposureKeys {
			if daysUntilToday >= 0 && daysUntilToday <= 14 {
				for exposureKey in exposureKeys {
					exposureKey.transmissionRiskLevel = symptomsOnset.transmissionRiskVector[daysUntilToday]
				}
			} else {
				groupedExposureKeys[daysUntilToday] = nil
			}
		}

		return groupedExposureKeys.values.flatMap { $0 }
	}

}
