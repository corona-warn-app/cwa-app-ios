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
	func processedForSubmission(with symptomsOnset: SymptomsOnset, today: Date = Date()) -> [SAP_External_Exposurenotification_TemporaryExposureKey] {
		/// 1. Group exposure keys by the day their rolling period started in the UTC time zone
		let groupedExposureKeys: [Int: Self] = Dictionary(grouping: self, by: {
			/// Use the rolling start number to get the date the rolling period started.
			/// The rollingStartNumber is the unix timestamp divided by 600, giving the amount of 10-minute-intervals that passed since 01.01.1970 00:00 UTC.
			let startDate = Date(timeIntervalSince1970: Double($0.rollingStartNumber) * 600)

			/// Make sure to use a calendar in UTC time zone with 24 hour days and leap seconds etc. in sync with the gregorian calendar
			var calendar = Calendar(identifier: .gregorian)
			guard let utcTimeZone = TimeZone(secondsFromGMT: 0) else { fatalError("Getting UTC time zone failed.") }
			calendar.timeZone = utcTimeZone

			/// Get the amount of days between start date and today to group the keys by that amount
			guard let ageInDays = calendar.dateComponents([.day], from: startDate, to: today).day else { fatalError("Getting days since rolling start day failed") }

			return ageInDays
		})

		/// 2. Assign the corresponding transmission risk levels and days since onset of symptoms. Keys that have no corresponding transmission risk level are filtered out.
		var processedExposureKeys = [SAP_External_Exposurenotification_TemporaryExposureKey]()
		for (ageInDays, exposureKeys) in groupedExposureKeys where ageInDays >= 0 && ageInDays <= 14 {
			for exposureKey in exposureKeys {
				/// Convert to SAP key struct for submission
				var sapExposureKey = exposureKey.sapKey

				/// Assign corresponding transmission risk level
				sapExposureKey.transmissionRiskLevel = symptomsOnset.transmissionRiskVector[ageInDays]

				/// Assign corresponding days since onset of symptoms
				sapExposureKey.daysSinceOnsetOfSymptoms = symptomsOnset.daysSinceOnsetOfSymptomsVector[ageInDays]

				processedExposureKeys.append(sapExposureKey)
			}
		}

		return processedExposureKeys
	}

}
