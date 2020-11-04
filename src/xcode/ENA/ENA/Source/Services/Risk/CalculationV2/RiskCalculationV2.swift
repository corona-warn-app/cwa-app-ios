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

final class RiskCalculationV2 {

	// MARK: - Internal

	/// Calculates the risk level based on exposure windows
	/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/7779cabcff42afb437f743f1d9e35592ef989c52/docs/spec/exposure-windows.md#aggregate-results-from-exposure-windows
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) throws -> RiskCalculationV2Result {
		/// 0. Filter by `Minutes at Attenuation` and `Transmission Risk Level`
		let filteredExposureWindows = exposureWindows
			.map { RiskCalculationWindow(exposureWindow: $0, configuration: configuration) }
			.filter { !$0.isDroppedByMinutesAtAttenuation && !$0.isDroppedByTransmissionRiskLevel }

		/// 1. Group `Exposure Windows by Date`
		let exposureWindowsPerDate = Dictionary(grouping: filteredExposureWindows, by: { $0.exposureWindow.date })

		/// 2. Determine `Normalized Time per Date`
		let normalizedTimePerDate = exposureWindowsPerDate.mapValues { windows in
			windows
				.map { $0.normalizedTime }
				.reduce(0, +)
		}

		/// 3. Determine `Risk Level per Date`
		let riskLevelPerDate = try normalizedTimePerDate.mapValues { normalizedTime -> CWARiskLevel in
			guard let riskLevel = configuration.normalizedTimePerDayToRiskLevelMapping
					.first(where: { $0.normalizedTimeRange.contains(normalizedTime) })
					.map({ $0.riskLevel })
			else {
				throw RiskCalculationV2Error.invalidConfiguration
			}

			return riskLevel
		}

		/// 4. Determine `Minimum Distinct Encounters With Low Risk per Date`
		let minimumDistinctEncountersWithLowRiskPerDate = try exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = try windows
				.filter { try $0.riskLevel() == .low }
				.map { "\($0.transmissionRiskLevel)_\($0.exposureWindow.calibrationConfidence.rawValue)" }

			return Set(trlAndConfidenceCombinations).count
		}

		/// 5. Determine `Minimum Distinct Encounters With High Risk per Date`
		let minimumDistinctEncountersWithHighRiskPerDate = try exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = try windows
				.filter { try $0.riskLevel() == .high }
				.map { "\($0.transmissionRiskLevel)_\($0.exposureWindow.calibrationConfidence.rawValue)" }

			return Set(trlAndConfidenceCombinations).count
		}

		/// 6. Determine `Total Risk`
		let riskLevel: EitherLowOrIncreasedRiskLevel = riskLevelPerDate.values.contains(.high) ? .increased : .low

		/// 7. Determine `Date of Most Recent Date with Low Risk`
		let mostRecentDateWithLowRisk = riskLevelPerDate.filter { $0.value == .low }.keys.max()

		/// 8. Determine `Date of Most Recent Date with High Risk`
		let mostRecentDateWithHighRisk = riskLevelPerDate.filter { $0.value == .high }.keys.max()

		/// 9. Determine `Total Minimum Distinct Encounters With Low Risk`
		let minimumDistinctEncountersWithLowRisk = minimumDistinctEncountersWithLowRiskPerDate.values.reduce(0, +)

		/// 10. Determine `Total Minimum Distinct Encounters With High Risk`
		let minimumDistinctEncountersWithHighRisk = minimumDistinctEncountersWithHighRiskPerDate.values.reduce(0, +)

		return RiskCalculationV2Result(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: minimumDistinctEncountersWithLowRisk,
			minimumDistinctEncountersWithHighRisk: minimumDistinctEncountersWithHighRisk,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			detectionDate: Date()
		)
	}

}
