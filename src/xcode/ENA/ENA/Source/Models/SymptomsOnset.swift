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

enum SymptomsOnset {

	case noInformation
	case nonSymptomatic
	case symptomaticWithUnknownOnset
	case lastSevenDays
	case oneToTwoWeeksAgo
	case moreThanTwoWeeksAgo
	case daysSinceOnset(Int)

	// MARK: - Internal

	/// Transmission risk level by days since the exposure.
	/// These factors are applied to each `ENTemporaryExposureKey`'s `transmissionRiskLevel`
	///
	/// Index 0 of the array represents the day of the exposure
	/// Index 1 the next day, and so on.
	/// These factors are supplied by RKI
	///
	/// - see also: [Risk Score Calculation Docs](https://github.com/corona-warn-app/cwa-documentation/blob/master/solution_architecture.md#risk-score-calculation)
	var transmissionRiskVector: [ENRiskLevel] {
		switch self {
		case .noInformation:
			return [5, 6, 7, 7, 7, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1]
		case .nonSymptomatic:
			return [4, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
		case .symptomaticWithUnknownOnset:
			return [5, 6, 8, 8, 8, 7, 5, 3, 2, 1, 1, 1, 1, 1, 1]
		case .lastSevenDays:
			return [4, 5, 6, 7, 7, 7, 6, 5, 4, 3, 2, 1, 1, 1, 1]
		case .oneToTwoWeeksAgo:
			return [1, 1, 1, 1, 2, 3, 4, 5, 6, 6, 7, 7, 6, 6, 4]
		case .moreThanTwoWeeksAgo:
			return [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 4, 5]
		case .daysSinceOnset(let daysSinceOnset):
			assert(daysSinceOnset < 22)
			return SymptomsOnset.daysSinceOnsetRiskVectors[min(daysSinceOnset, 21)]
		}
	}

	/// Days since onset of symptoms according to https://github.com/corona-warn-app/cwa-app-tech-spec/blob/56521167b688f418127adde09a18a48f262af382/docs/spec/days-since-onset-of-symptoms.md
	var daysSinceOnsetOfSymptomsVector: [Int] {
		switch self {
		case .noInformation:
			return Array(3986...4000).reversed()
		case .nonSymptomatic:
			return Array(2986...3000).reversed()
		case .symptomaticWithUnknownOnset:
			return Array(1986...2000).reversed()
		case .lastSevenDays:
			return Array(687...701).reversed()
		case .oneToTwoWeeksAgo:
			return Array(694...708).reversed()
		case .moreThanTwoWeeksAgo:
			return Array(701...715).reversed()
		case .daysSinceOnset(let daysSinceOnset):
			return Array(-14...0).reversed().map { $0 + daysSinceOnset }
		}
	}

	// MARK: - Private

	private static let daysSinceOnsetRiskVectors: [[ENRiskLevel]] = [
		[8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1, 1],
		[6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1, 1],
		[5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1, 1],
		[3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1, 1],
		[2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1, 1],
		[2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1, 1],
		[1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1, 1],
		[1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2, 1],
		[1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4, 2],
		[1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6, 4],
		[1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7, 6],
		[1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8, 7],
		[1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6, 8],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5, 6],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3, 5],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 3],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
	]

}
