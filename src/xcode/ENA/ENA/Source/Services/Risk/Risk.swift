//
// 🦠 Corona-Warn-App
//

import Foundation

struct Risk: Equatable {

	struct Details: Equatable {
		var mostRecentDateWithRiskLevel: Date?
		var numberOfDaysWithRiskLevel: Int
		var calculationDate: Date?
	}

	enum RiskLevelChange: Equatable {
		case increased
		case decreased
		case unchanged(RiskLevel)
	}

	let level: RiskLevel
	let details: Details
	let riskLevelChange: RiskLevelChange

	var riskLevelHasChanged: Bool {
		switch riskLevelChange {
		case .increased, .decreased:
			return true
		case .unchanged:
			return false
		}
	}

}

extension Risk {
	init(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		previousENFRiskCalculationResult: ENFRiskCalculationResult? = nil,
		checkinCalculationResult: CheckinRiskCalculationResult,
		previousCheckinCalculationResult: CheckinRiskCalculationResult? = nil
	) {
		Log.info("[Risk] Merging risks from ENF and checkin. Create Risk.", log: .riskDetection)

		// Check for each risk source (enf and checkin) if one of them got high. Only needed for PPA.
		if previousENFRiskCalculationResult?.riskLevel == .low &&
			enfRiskCalculationResult.riskLevel == .high {
			Log.debug("[Risk] ENF riskLevel has changed to high.", log: .riskDetection)
			Analytics.collect(.testResultMetadata(.setDateOfConversionToENFHighRisk(Date())))
		}
		if previousCheckinCalculationResult?.riskLevel == .low &&
			checkinCalculationResult.riskLevel == .high {
			Log.debug("[Risk] Checkin riskLevel has changed to high.", log: .riskDetection)
			Analytics.collect(.testResultMetadata(.setDateOfConversionToCheckinHighRisk(Date())))
		}

		let totalRiskLevel = Self.totalRiskLevel(
			enfRiskCalculationResult: enfRiskCalculationResult,
			checkinCalculationResult: checkinCalculationResult
		)
		Log.debug("[Risk] totalRiskLevel: \(totalRiskLevel)", log: .riskDetection)
		
		var previousTotalRiskLevel: RiskLevel = .low

		if let previousENFRiskLevel = previousENFRiskCalculationResult,
		   let previousCheckinRiskLevel = previousCheckinCalculationResult {

			previousTotalRiskLevel = Self.totalRiskLevel(
				enfRiskCalculationResult: previousENFRiskLevel,
				checkinCalculationResult: previousCheckinRiskLevel
			)
		} else if let previousENFRiskLevel = previousENFRiskCalculationResult {
			previousTotalRiskLevel = previousENFRiskLevel.riskLevel
		} else if let previousCheckinRiskLevel = previousCheckinCalculationResult {
			previousTotalRiskLevel = previousCheckinRiskLevel.riskLevel
		}
		
		Log.debug("[Risk] previousTotalRiskLevel: \(previousTotalRiskLevel)", log: .riskDetection)

		let riskLevelChange: RiskLevelChange
		if previousTotalRiskLevel == totalRiskLevel {
			riskLevelChange = .unchanged(totalRiskLevel)
		} else {
			riskLevelChange = previousTotalRiskLevel > totalRiskLevel ? .decreased : .increased
		}
		
		Log.debug("[Risk] riskLevelChange: \(riskLevelChange)", log: .riskDetection)

		let details = Self.riskDetails(
			enfRiskCalculationResult: enfRiskCalculationResult,
			checkinCalculationResult: checkinCalculationResult,
			riskLevel: totalRiskLevel
		)
		
		Log.debug("[Risk] details: \(details)", log: .riskDetection)

		self.init(
			level: totalRiskLevel,
			details: details,
			riskLevelChange: riskLevelChange
		)
	}
	
	private static func totalRiskLevel(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		checkinCalculationResult: CheckinRiskCalculationResult
	) -> RiskLevel {
		let mergedRiskLevelPerDate = mergedRiskLevelPerDate(
			enfRiskCalculationResult: enfRiskCalculationResult,
			checkinCalculationResult: checkinCalculationResult
		)

		Log.debug("[Risk] mergedRiskLevelPerDate: \(mergedRiskLevelPerDate)", log: .riskDetection)

		// The Total Risk Level is High if there is least one Date with Risk Level per Date calculated as High; it is Low otherwise.
		var totalRiskLevel: RiskLevel = .low
		if mergedRiskLevelPerDate.contains(where: {
			$0.value == .high
		}) {
			totalRiskLevel = .high
		}
		
		return totalRiskLevel
	}
	
	private static func riskDetails(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		checkinCalculationResult: CheckinRiskCalculationResult,
		riskLevel: RiskLevel
	) -> Details {
		
		let mergedRiskLevelPerDate = Self.mergedRiskLevelPerDate(
			enfRiskCalculationResult: enfRiskCalculationResult,
			checkinCalculationResult: checkinCalculationResult
		)
		
		// 1. Filter for the desired risk.
		// 2. Select the maximum by date (the most current).
		let mostRecentDateWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == riskLevel
		}.max(by: {
			$0.key < $1.key
		})?.key

		Log.debug("[Risk] mostRecentDateWithRiskLevel: \(String(describing: mostRecentDateWithRiskLevel))", log: .riskDetection)

		let numberOfDaysWithRiskLevel = mergedRiskLevelPerDate.filter {
			$1 == riskLevel
		}.count

		Log.debug("[Risk] numberOfDaysWithRiskLevel: \(numberOfDaysWithRiskLevel)", log: .riskDetection)

		let calculationDate = max(enfRiskCalculationResult.calculationDate, checkinCalculationResult.calculationDate)

		let details = Details(
			mostRecentDateWithRiskLevel: mostRecentDateWithRiskLevel,
			numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
			calculationDate: calculationDate
		)
		
		return details
	}
	
	// Merge the results from both risk calculation. For each date, the highest risk level is used.
	private static func mergedRiskLevelPerDate(
		enfRiskCalculationResult: ENFRiskCalculationResult,
		checkinCalculationResult: CheckinRiskCalculationResult
	) -> [Date: RiskLevel] {
		let tracingRiskLevelPerDate = enfRiskCalculationResult.riskLevelPerDate
		let checkinRiskLevelPerDate = checkinCalculationResult.riskLevelPerDate
		
		Log.debug("[Risk] tracingRiskLevelPerDate: \(tracingRiskLevelPerDate)", log: .riskDetection)
		Log.debug("[Risk] checkinRiskLevelPerDate: \(checkinRiskLevelPerDate)", log: .riskDetection)
		
		// Merge the results from both risk calculation. For each date, the higher risk level is used.
		let mergedRiskLevelPerDate = tracingRiskLevelPerDate.merging(checkinRiskLevelPerDate) { lhs, rhs -> RiskLevel in
			max(lhs, rhs)
		}
		
		return mergedRiskLevelPerDate
	}
}

#if DEBUG
extension Risk {
	static let numberOfDaysWithRiskLevel = LaunchArguments.risk.numberOfDaysWithRiskLevel.intValue
	static let numberOfDaysWithRiskLevelDefaultValue: Int = LaunchArguments.risk.riskLevel.stringValue == "high" ? 1 : 0
	static let mocked: Risk = {
		let level: RiskLevel = LaunchArguments.risk.riskLevel.stringValue == "high" ? .high : .low
		return Risk(
			// UITests can set app.launchArguments LaunchArguments.risk.riskLevel
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
				calculationDate: Date()),
			riskLevelChange: level == .high ? .increased : .decreased
		)
	}()

	static func mocked(
		level: RiskLevel = .low,
		riskLevelChange: RiskLevelChange = .decreased
	) -> Risk {
		Risk(
			level: level,
			details: Risk.Details(
				mostRecentDateWithRiskLevel: Date(timeIntervalSinceNow: -24 * 3600),
				numberOfDaysWithRiskLevel: numberOfDaysWithRiskLevel,
				calculationDate: Date()),
			riskLevelChange: riskLevelChange
		)
	}
}
#endif
