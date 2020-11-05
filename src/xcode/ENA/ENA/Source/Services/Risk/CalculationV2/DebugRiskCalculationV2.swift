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

#if !RELEASE

import Foundation

struct blae {
	private(set) var mappedExposureWindows: [RiskCalculationExposureWindow] = []
	private(set) var filteredExposureWindows: [RiskCalculationExposureWindow] = []
	private(set) var exposureWindowsPerDate: [Date: [RiskCalculationExposureWindow]] = [:]
	private(set) var normalizedTimePerDate: [Date: Double] = [:]
	private(set) var riskLevelPerDate: [Date: CWARiskLevel] = [:]
	private(set) var minimumDistinctEncountersWithLowRiskPerDate: [Date: Int] = [:]
	private(set) var minimumDistinctEncountersWithHighRiskPerDate: [Date: Int] = [:]
	private(set) var riskLevel: EitherLowOrIncreasedRiskLevel = .low
	private(set) var mostRecentDateWithLowRisk: Date?
	private(set) var mostRecentDateWithHighRisk: Date?
	private(set) var minimumDistinctEncountersWithLowRisk = 0
	private(set) var minimumDistinctEncountersWithHighRisk = 0
}

final class DebugRiskCalculationV2 {

	init(
		riskCalculation: RiskCalculationV2,
		store: Store
	) {
		self.riskCalculation = riskCalculation
		self.store = store
	}

	private let riskCalculation: RiskCalculationV2
	private let store: Store

	// MARK: - Internal

	/// Calculates the risk level based on exposure windows
	/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/7779cabcff42afb437f743f1d9e35592ef989c52/docs/spec/exposure-windows.md#aggregate-results-from-exposure-windows
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) throws -> RiskCalculationV2Result {
		let riskCalculationResult = try riskCalculation.calculateRisk(exposureWindows: exposureWindows, configuration: configuration)

		store.mostRecentRiskCalculation = riskCalculation
		store.mostRecentRiskCalculationConfiguration = configuration

		return riskCalculationResult
	}

}

#endif
