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

enum CWARiskLevel: Int, Decodable {

	// MARK: - Init

	init(from riskLevel: SAP_Internal_V2_NormalizedTimeToRiskLevelMapping.RiskLevel) {
		switch riskLevel {
		case .low:
			self = .low
		case .high:
			self = .high
		default:
			fatalError("Only low and high risk levels are supported")
		}
	}

	// MARK: - Internal

	case low = 1
	case high = 2

	var eitherLowOrIncreasedRiskLevel: EitherLowOrIncreasedRiskLevel {
		switch self {
		case .low:
			return .low
		case .high:
			return .increased
		}
	}

}
