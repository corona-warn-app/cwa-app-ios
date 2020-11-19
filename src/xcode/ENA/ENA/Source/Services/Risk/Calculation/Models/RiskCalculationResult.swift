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

struct RiskCalculationResult: Codable {

	// MARK: - Internal

	let riskLevel: RiskLevel

	let minimumDistinctEncountersWithLowRisk: Int
	let minimumDistinctEncountersWithHighRisk: Int

	let mostRecentDateWithLowRisk: Date?
	let mostRecentDateWithHighRisk: Date?

	let numberOfDaysWithLowRisk: Int
	let numberOfDaysWithHighRisk: Int

	let calculationDate: Date

	var minimumDistinctEncountersWithCurrentRiskLevel: Int {
		switch riskLevel {
		case .low:
			return minimumDistinctEncountersWithLowRisk
		case .high:
			return minimumDistinctEncountersWithHighRisk
		}
	}

	var mostRecentDateWithCurrentRiskLevel: Date? {
		switch riskLevel {
		case .low:
			return mostRecentDateWithLowRisk
		case .high:
			return mostRecentDateWithHighRisk
		}
	}

	var numberOfDaysWithCurrentRiskLevel: Int {
		switch riskLevel {
		case .low:
			return numberOfDaysWithLowRisk
		case .high:
			return numberOfDaysWithHighRisk
		}
	}

}

extension Risk.Details {

	init(
		activeTracing: ActiveTracing,
		riskCalculationResult: RiskCalculationResult
	) {
		self.init(
			mostRecentDateWithRiskLevel: riskCalculationResult.mostRecentDateWithCurrentRiskLevel,
			numberOfDaysWithRiskLevel: riskCalculationResult.numberOfDaysWithCurrentRiskLevel,
			activeTracing: activeTracing,
			exposureDetectionDate: riskCalculationResult.calculationDate
		)
	}

}

extension Risk {

	init(
		activeTracing: ActiveTracing,
		riskCalculationResult: RiskCalculationResult,
		previousRiskCalculationResult: RiskCalculationResult? = nil
	) {
		let riskLevelHasChanged = previousRiskCalculationResult?.riskLevel != nil && riskCalculationResult.riskLevel != previousRiskCalculationResult?.riskLevel

		self.init(
			level: riskCalculationResult.riskLevel == .high ? .high : .low,
			details: Details(activeTracing: activeTracing, riskCalculationResult: riskCalculationResult),
			riskLevelHasChanged: riskLevelHasChanged
		)
	}

}
