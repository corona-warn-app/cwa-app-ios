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

struct ExposureDetectionResult {

	let riskLevel: EitherLowOrIncreasedRiskLevel

	let minimumDistinctEncountersWithLowRisk: Int
	let minimumDistinctEncountersWithHighRisk: Int

	let mostRecentDateWithLowRisk: Date?
	let mostRecentDateWithHighRisk: Date?

	let numberOfExposureWindowsWithLowRisk: Int
	let numberOfExposureWindowsWithHighRisk: Int

	let detectionDate: Date

	var minimumDistinctEncountersWithCurrentRiskLevel: Int {
		switch riskLevel {
		case .low:
			return minimumDistinctEncountersWithLowRisk
		case .increased:
			return minimumDistinctEncountersWithHighRisk
		}
	}

	var mostRecentDateWithCurrentRiskLevel: Date? {
		switch riskLevel {
		case .low:
			return mostRecentDateWithLowRisk
		case .increased:
			return mostRecentDateWithHighRisk
		}
	}

	var ageInDaysOfMostRecentDateWithLowRisk: Int? {
		guard let mostRecentDateWithLowRisk = mostRecentDateWithLowRisk else {
			return nil
		}

		return Calendar.current.dateComponents([.day], from: mostRecentDateWithLowRisk, to: Date()).day
	}

	var ageInDaysOfMostRecentDateWithHighRisk: Int? {
		guard let mostRecentDateWithHighRisk = mostRecentDateWithHighRisk else {
			return nil
		}

		return Calendar.current.dateComponents([.day], from: mostRecentDateWithHighRisk, to: Date()).day
	}

}
