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
	func processedForSubmission(with symptomsOnset: SymptomsOnset, today: Date = Date()) -> [ENTemporaryExposureKey] {
		/// 1. Group exposure keys by the day their rolling period started in the UTC timezone
		var groupedExposureKeys: [Int: Self] = Dictionary(grouping: self, by: {
			/// Use the rolling start number to get the date the rolling period started.
			/// The rollingStartNumber is the unix timestamp divided by 600, giving the amount of of 10-minute-intervals that passed since 01.01.1970 00:00 UTC.
			let startDate = Date(timeIntervalSince1970: Double($0.rollingStartNumber) * 600)

			/// Make sure to use a calendar in UTC timezone with 24 hour days and leap seconds etc. in sync with the gregorian calendar
			var calendar = Calendar(identifier: .gregorian)
			// swiftlint:disable:next force_unwrapping
			calendar.timeZone = TimeZone(secondsFromGMT: 0)!

			/// Get the amount of days between start date and today to group the keys by that amount
			guard let daysUntilToday = calendar.dateComponents([.day], from: startDate, to: today).day else { fatalError("Getting days since rolling start day failed") }

			return daysUntilToday
		})

		/// 2. Assign the corresponding transmission risk levels and filter out keys that have no corresponding transmission risk level
		for (daysUntilToday, exposureKeys) in groupedExposureKeys {
			if daysUntilToday >= 0 && daysUntilToday <= 14 {
				for exposureKey in exposureKeys {
					/// Assign corresponding transmission risk level
					exposureKey.transmissionRiskLevel = symptomsOnset.transmissionRiskVector[daysUntilToday]
				}
			} else {
				/// Remove keys that have no corresponding transmission risk level
				groupedExposureKeys[daysUntilToday] = nil
			}
		}

		// Flatten dictionary [[0] -> [Key0], [1] -> [Key1, Key2]] to unsorted array [Key1, Key2, Key0]
		return groupedExposureKeys.values.flatMap { $0 }
	}

}
