//
// 🦠 Corona-Warn-App
//

import Foundation

protocol RiskCalculationProtocol {

	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) -> RiskCalculationResult
	
	var mappedExposureWindows: [RiskCalculationExposureWindow] { get set }
}

final class RiskCalculation: RiskCalculationProtocol, Codable {

	// MARK: - Internal

	var mappedExposureWindows: [RiskCalculationExposureWindow] = []
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
	private(set) var numberOfDaysWithLowRisk = 0
	private(set) var numberOfDaysWithHighRisk = 0
	private(set) var calculationDate = Date()

	/// Calculates the risk level based on exposure windows
	/// https://github.com/corona-warn-app/cwa-app-tech-spec/blob/7779cabcff42afb437f743f1d9e35592ef989c52/docs/spec/exposure-windows.md#aggregate-results-from-exposure-windows
	func calculateRisk(
		exposureWindows: [ExposureWindow],
		configuration: RiskCalculationConfiguration
	) -> RiskCalculationResult {
		Log.info("[RiskCalculation] Started risk calculation", log: .riskDetection)

		mappedExposureWindows = exposureWindows
			.map { RiskCalculationExposureWindow(exposureWindow: $0, configuration: configuration) }

		/// 0. Filter by `Risk Level`, `Minutes at Attenuation`, and `Transmission Risk Level`
		filteredExposureWindows = mappedExposureWindows
			.filter { $0.riskLevel != nil && !$0.isDroppedByMinutesAtAttenuation && !$0.isDroppedByTransmissionRiskLevel }

		/// 1. Group `Exposure Windows by Date`
		exposureWindowsPerDate = Dictionary(grouping: filteredExposureWindows, by: { $0.date })

		/// 2. Determine `Normalized Time per Date`
		normalizedTimePerDate = exposureWindowsPerDate.mapValues { windows in
			windows
				.map { $0.normalizedTime }
				.reduce(0, +)
		}

		/// 3. Determine `Risk Level per Date`
		riskLevelPerDate = normalizedTimePerDate.compactMapValues { normalizedTime -> RiskLevel? in
			configuration.normalizedTimePerDayToRiskLevelMapping
				.first(where: { $0.normalizedTimeRange.contains(normalizedTime) })?
				.riskLevel
		}

		/// 4. Determine `Minimum Distinct Encounters With Low Risk per Date`
		minimumDistinctEncountersWithLowRiskPerDate = exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = windows
				.filter { $0.riskLevel == .low }
				.map { "\($0.transmissionRiskLevel)_\($0.calibrationConfidence.rawValue)" }

			return Set(trlAndConfidenceCombinations).count
		}

		/// 5. Determine `Minimum Distinct Encounters With High Risk per Date`
		minimumDistinctEncountersWithHighRiskPerDate = exposureWindowsPerDate.mapValues { windows -> Int in
			let trlAndConfidenceCombinations = windows
				.filter { $0.riskLevel == .high }
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

		/// 11. Determine `Number of Days With Low Risk`
		numberOfDaysWithLowRisk = riskLevelPerDate.filter { $0.value == .low }.count

		/// 12. Determine `Number of Days With High Risk`
		numberOfDaysWithHighRisk = riskLevelPerDate.filter { $0.value == .high }.count

		Log.info("[RiskCalculation] Finished risk calculation", log: .riskDetection)

		calculationDate = Date()

		return RiskCalculationResult(
			riskLevel: riskLevel,
			minimumDistinctEncountersWithLowRisk: minimumDistinctEncountersWithLowRisk,
			minimumDistinctEncountersWithHighRisk: minimumDistinctEncountersWithHighRisk,
			mostRecentDateWithLowRisk: mostRecentDateWithLowRisk,
			mostRecentDateWithHighRisk: mostRecentDateWithHighRisk,
			numberOfDaysWithLowRisk: numberOfDaysWithLowRisk,
			numberOfDaysWithHighRisk: numberOfDaysWithHighRisk,
			calculationDate: calculationDate,
			riskLevelPerDate: riskLevelPerDate,
			minimumDistinctEncountersWithHighRiskPerDate: minimumDistinctEncountersWithHighRiskPerDate
		)
	}

}
