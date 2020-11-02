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
@testable import ENA

struct ExposureWindowTestCase: Decodable {

	// MARK: - Protocol Decodable

	enum CodingKeys: String, CodingKey {
		case testCaseDescription = "description"
		case exposureWindows, expTotalRiskLevel, expTotalMinimumDistinctEncountersWithLowRisk, expAgeOfMostRecentDateWithLowRisk, expAgeOfMostRecentDateWithHighRisk, expTotalMinimumDistinctEncountersWithHighRisk, expNumberOfExposureWindowsWithLowRisk, expNumberOfExposureWindowsWithHighRisk
	}

	// MARK: - Internal

	let testCaseDescription: String
	let exposureWindows: [ENA.ExposureWindow]
	let expTotalRiskLevel: CWARiskLevel
	let expTotalMinimumDistinctEncountersWithLowRisk: Int
	let expAgeOfMostRecentDateWithLowRisk: Int?
	let expAgeOfMostRecentDateWithHighRisk: Int?
	let expTotalMinimumDistinctEncountersWithHighRisk: Int
	let expNumberOfExposureWindowsWithLowRisk: Int?
	let expNumberOfExposureWindowsWithHighRisk: Int?

}
