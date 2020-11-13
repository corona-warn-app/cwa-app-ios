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

protocol RiskCalculationV2Protocol {

	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) throws -> RiskCalculationV2Result

}

final class RiskCalculationV2: RiskCalculationV2Protocol, Codable {

	// MARK: - Internal

	private(set) var mappedExposureWindows: [RiskCalculationExposureWindow] = []
	private(set) var filteredExposureWindows: [RiskCalculationExposureWindow] = []
	private(set) var exposureWindowsPerDate: [Date: [RiskCalculationExposureWindow]] = [:]
	private(set) var normalizedTimePerDate: [Date: Double] = [:]
	private(set) var riskLevelPerDate: [Date: RiskLevel] = [:]
	private(set) var minimumDistinctEncountersWithLowRiskPerDate: [Date: Int] = [:]
	private(set) var minimumDistinctEncountersWithHighRiskPerDate: [Date: Int] = [:]
	private(set) var riskLevel: RiskLevel = .low
	private(set) var mostRecentDateWithLowRisk: Date?
	private(set) var mostRecentDateWithHighRisk: Date?
	private(set) var minimumDistinctEncountersWithLowRisk = 0
	private(set) var minimumDistinctEncountersWithHighRisk = 0
	private(set) var calculationDate = Date()

	/// Calculates the risk level based on exposure windows
	/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/7779cabcff42afb437f743f1d9e35592ef989c52/docs/spec/exposure-windows.md#aggregate-results-from-exposure-windows
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) throws -> RiskCalculationV2Result {
		mappedExposureWindows = exposureWindows
			.map { RiskCalculationExposureWindow(exposureWindow: $0, configuration: configuration) }

		/// 0. Filter by `Minutes at Attenuation` and `Transmission Risk Level`
		filteredExposureWindows = mappedExposureWindows
			.filter { !$0.isDroppedByMinutesAtAttenuation && !$0.isDroppedByTransmissionRiskLevel }

		/// 1. Group `Exposure Windows by Date`
		exposureWindowsPerDate = Dictionary(grouping: filteredExposureWindows, by: { $0.date })

		/// 2. Determine `Normalized Time per Date`
		normalizedTimePerDate = exposureWindowsPerDate.mapValues { windows in
			windows
				.map { $0.normalizedTime }
				.reduce(0, +)
		}

		/// 3. Determine `Risk Level per Date`
		riskLevelPerDate = try normalizedTimePerDate.mapValues { normalizedTime -> RiskLevel in
			guard let riskLevel = configuration.normalizedTimePerDayToRiskLevelMapping
					.first(where: { $0.normalizedTimeRange.contains(normalizedTime) })
					.map({ $0.riskLevel })
			else {
				throw RiskCalculationV2Error.invalidConfiguration
			}

			return riskLevel
		}

		/// 4. Determine `Minimum Distinct Encounters With Low Risk per Date`
		minimumDistinctEncountersWithLowRiskPerDate = try exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = try windows
				.filter { try $0.riskLevel() == .low }
				.map { "\($0.transmissionRiskLevel)_\($0.calibrationConfidence.rawValue)" }

			return Set(trlAndConfidenceCombinations).count
		}

		/// 5. Determine `Minimum Distinct Encounters With High Risk per Date`
		minimumDistinctEncountersWithHighRiskPerDate = try exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = try windows
				.filter { try $0.riskLevel() == .high }
				.map { "\($0.transmissionRiskLevel)_\($0.calibrationConfidence.rawValue)" }

			return Set(trlAndConfidenceCombinations).count
		}

		/// 6. Determine `Total Risk`
		riskLevel = riskLevelPerDate.values.contains(.high) ? .high : .low

		/// 7. Determine `Date of Most Recent Date with Low Risk`
		mostRecentDateWithLowRisk = riskLevelPerDate.filter { $0.value == .low }.keys.max()

		/// 8. Determine `Date of Most Recent Date with High Risk`
		mostRecentDateWithHighRisk = riskLevelPerDate.filter { $0.value == .high }.keys.max()

		/// 9. Determine `Total Minimum Distinct Encounters With Low Risk`
		minimumDistinctEncountersWithLowRisk = minimumDistinctEncountersWithLowRiskPerDate.values.reduce(0, +)

		/// 10. Determine `Total Minimum Distinct Encounters With High Risk`
		minimumDistinctEncountersWithHighRisk = minimumDistinctEncountersWithHighRiskPerDate.values.reduce(0, +)

		calculationDate = Date()

		return RiskCalculationV2Result(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: minimumDistinctEncountersWithLowRisk,
			minimumDistinctEncountersWithHighRisk: minimumDistinctEncountersWithHighRisk,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			calculationDate: calculationDate
		)
	}

}
